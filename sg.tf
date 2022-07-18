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
      description = "external to LB"
      cidr_blocks = "0.0.0.0/0"
    
    }
    ]
}
