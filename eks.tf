provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
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

  }


  # aws-auth configmap
  manage_aws_auth_configmap = true
 
  

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::813224394680:group/2soAdmin"
      usergroup = "2soAdmin"
      groups   = ["system:masters"]
    }
  
   
  ]

  
  
  tags = {
    Terraform = "true"
    Project = "${var.project_name}"
    Environment = "${terraform.workspace}"
    
  }
}




