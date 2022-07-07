
locals {

cluster_name = "${var.project_name}-${terraform.workspace}"
#Private Subnets
private_subnet_1 = cidrsubnet("${local.vpc_cidr}", 8, 1)
private_subnet_2 = cidrsubnet("${local.vpc_cidr}", 8, 2)
private_subnet_3 = cidrsubnet("${local.vpc_cidr}", 8, 3)

#Public Subnets
public_subnet_1 = cidrsubnet("${local.vpc_cidr}", 8, 11)
public_subnet_2 = cidrsubnet("${local.vpc_cidr}", 8, 12)
public_subnet_3 = cidrsubnet("${local.vpc_cidr}", 8, 13)

/* #Database Subnets
database_subnet_1 = cidrsubnet("${local.vpc_cidr}", 8, 21)
database_subnet_2 = cidrsubnet("${local.vpc_cidr}", 8, 22)
database_subnet_3 = cidrsubnet("${local.vpc_cidr}", 8, 23) */

project_name = "obligatorio"

aws_region = "us-east-1"

vpc_cidr = "10.0.0.0/16"

}

resource "aws_eip" "nat" {
  vpc   = true
}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.project_name}-${terraform.workspace}"
  cidr = "${local.vpc_cidr}"

  azs             = ["${local.aws_region}a", "${local.aws_region}b", "${local.aws_region}c"]
  private_subnets = ["${local.private_subnet_1}", "${local.private_subnet_2}", "${local.private_subnet_3}"]
  public_subnets  = ["${local.public_subnet_1}", "${local.public_subnet_2}", "${local.public_subnet_3}"]
  #database_subnets = ["${local.database_subnet_1}", "${local.database_subnet_2}", "${local.database_subnet_3}"]

  create_vpc          = true
  create_igw          = true

  enable_nat_gateway  = true
  single_nat_gateway  = true
  reuse_nat_ips       = true  
  external_nat_ip_ids = "${aws_eip.nat.id}"                   
       
  

  tags = {
    Terraform = "true"
    Project = "${var.project_name}"
    Environment = "${terraform.workspace}"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = local.cluster_name
  }
}