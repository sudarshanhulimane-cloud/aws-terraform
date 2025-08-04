# Route 53 Hosted Zone
resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-hosted-zone"
  })
}

# A record for ALB
resource "aws_route53_record" "alb" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# A record for bastion host
resource "aws_route53_record" "bastion" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "bastion.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.bastion_public_ip]
}