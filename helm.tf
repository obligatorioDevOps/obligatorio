
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    }
  }
}



resource "helm_release" "aws-load-balancer-controller" {
  namespace        = "kube-system"
  create_namespace = false

  name       = "eks-aws-elb"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "v1.4.2"

  set {
    name  = "serviceAccount.create"
    value = false
  }

  set {
    name  = "clusterName"
    value = module.eks.cluster_id
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

## https://aws.amazon.com/premiumsupport/knowledge-center/eks-alb-ingress-aws-waf/

} 

resource "helm_release" "external-dns" {
  
  name       = "eks-external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "v6.5.6"

  set {
    name  = "serviceAccount.create"
    value = false
  }

}

