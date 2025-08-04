# DNS Module Outputs

output "hosted_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "name_servers" {
  description = "Route 53 name servers"
  value       = aws_route53_zone.main.name_servers
}

output "alb_dns_record" {
  description = "ALB DNS record"
  value       = aws_route53_record.alb.name
}

output "bastion_dns_record" {
  description = "Bastion DNS record"
  value       = aws_route53_record.bastion.name
}

output "api_dns_record" {
  description = "API DNS record"
  value       = aws_route53_record.api.name
}

output "admin_dns_record" {
  description = "Admin DNS record"
  value       = aws_route53_record.admin.name
}