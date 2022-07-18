resource "aws_route53_zone" "primary" {
  name = var.route53_domain_name
}

resource "aws_route53_zone" "private" {
  name = var.route53_domain_name

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_route53_record" "products" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "products"
  type    = "A"
 
  
  alias {
    name                   = aws_lb.obligatorio.dns_name
    zone_id                = aws_lb.obligatorio.zone_id
    evaluate_target_health = false
  }
  
}

resource "aws_route53_record" "orders" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "orders"
  type    = "A"
 
  
  alias {
    name                   = aws_lb.obligatorio.dns_name
    zone_id                = aws_lb.obligatorio.zone_id
    evaluate_target_health = false
  }
  
}

resource "aws_route53_record" "payments" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "payments"
  type    = "A"
 
  
  alias {
    name                   = aws_lb.obligatorio.dns_name
    zone_id                = aws_lb.obligatorio.zone_id
    evaluate_target_health = false
  }
  
}

resource "aws_route53_record" "shipping" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "shipping"
  type    = "A"
 
  
  alias {
    name                   = aws_lb.obligatorio.dns_name
    zone_id                = aws_lb.obligatorio.zone_id
    evaluate_target_health = false
  }
  
}