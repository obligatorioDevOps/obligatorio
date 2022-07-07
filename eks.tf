provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = "${var.project_name}-${terraform.workspace}"
  cluster_version = "1.22"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

 cluster_security_group_additional_rules = {
    ingress_nodes_karpenter_ports_tcp = {
      description                = "Karpenter readiness"
      protocol                   = "tcp"
      from_port                  = 8443
      to_port                    = 8443
      type                       = "ingress"
      source_node_security_group = true
    }
  }
  
  node_security_group_additional_rules = {
    aws_lb_controller_webhook = {
      description                   = "Cluster API to AWS LB Controller webhook"
      protocol                      = "all"
      from_port                     = 9443
      to_port                       = 9443
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }  
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    disk_size      = 50
   # instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    initial = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT" # ON_DEMAND or SPOT
    }
    /* green = {    
    } */
  }


  # aws-auth configmap
  manage_aws_auth_configmap = true
  #create_aws_auth_configmap = true
  

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::683436160523:role/AWSReservedSSO_Admin_d65c2f88bffdc84b"
      username = "Admin:{{SessionName}}"
      groups   = ["system:masters"]
    }
    
  ]
  
  tags = {
    Terraform = "true"
    Project = "${var.project_name}"
    Environment = "${terraform.workspace}"
    "karpenter.sh/discovery" = local.cluster_name
  }
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile-${local.cluster_name}"
  role = module.eks.eks_managed_node_groups["initial"].iam_role_name
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

resource "kubectl_manifest" "karpenter_provisioner" {
  yaml_body = <<-YAML
  apiVersion: karpenter.sh/v1alpha5
  kind: Provisioner
  metadata:
    name: default
  spec:
    requirements:
      - key: karpenter.sh/capacity-type
        operator: In
        values: ["spot"]
    limits:
      resources:
        cpu: 1000
    provider:
      subnetSelector:
        karpenter.sh/discovery: ${local.cluster_name}
      securityGroupSelector:
        karpenter.sh/discovery: ${local.cluster_name}
      tags:
        karpenter.sh/discovery: ${local.cluster_name}
    ttlSecondsAfterEmpty: 30
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "aws-load-balancer-controller-serviceaccount" {
  yaml_body = <<-YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::6834361605233:role/AmazonEKSLoadBalancerControllerRole
  YAML
  
}