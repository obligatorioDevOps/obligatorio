terraform {
  required_version = "~> 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.18"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.4"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
    
  }

  

  backend "s3" {
    bucket  = "obligatorio-abdm-terraform"
    key     = "obligatorio.tfstate"
    region  = "us-east-1"
    encrypt = true
    
    
  }
}

provider "aws" {
  region  = "us-east-1"
  
  
}

data "aws_partition" "current" {}




