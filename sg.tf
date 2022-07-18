module "sg_external_alb" {
  source = "terraform-aws-modules/security-group/aws"

  name = "external_alb"  
  description = "Security group for external connections"
  vpc_id      = module.vpc.vpc_id
    egress_rules  = ["all-all"]

    ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "external to public subnet1"
      cidr_blocks = "${module.vpc.public_subnets_cidr_blocks[0]}"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "external to public subnet2"
      cidr_blocks = "${module.vpc.public_subnets_cidr_blocks[1]}"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "external to public subnet3"
      cidr_blocks = "${module.vpc.public_subnets_cidr_blocks[2]}"
    },
    
  ]
}
