resource "aws_route53_zone" "primary" {
  name = var.route53_domain_name
}

resource "aws_route53_zone" "private" {
  name = var.route53_domain_name

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}