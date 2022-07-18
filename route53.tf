resource "aws_route53_zone" "primary" {
  name = var.route53_domain_name
}





resource "aws_route53_record" "obligatorio" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "obligatorio"
  type    = "A"
 
  
  alias {
    name                   = aws_lb.obligatorio.dns_name
    zone_id                = aws_lb.obligatorio.zone_id
    evaluate_target_health = false
  }
  
}



