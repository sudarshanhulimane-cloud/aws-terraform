output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "alb_hosted_zone_id" {
  description = "Canonical hosted zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN of the HTTP target group"
  value       = aws_lb_target_group.http.arn
}

output "target_group_id" {
  description = "ID of the HTTP target group"
  value       = aws_lb_target_group.http.id
}

output "target_group_name" {
  description = "Name of the HTTP target group"
  value       = aws_lb_target_group.http.name
}

output "https_target_group_arn" {
  description = "ARN of the HTTPS target group"
  value       = var.create_https_target_group ? aws_lb_target_group.https[0].arn : null
}

output "https_target_group_id" {
  description = "ID of the HTTPS target group"
  value       = var.create_https_target_group ? aws_lb_target_group.https[0].id : null
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = var.enable_https ? aws_lb_listener.https[0].arn : null
}

output "target_group_arns" {
  description = "List of all target group ARNs"
  value = concat(
    [aws_lb_target_group.http.arn],
    var.create_https_target_group ? [aws_lb_target_group.https[0].arn] : []
  )
}

output "listener_arns" {
  description = "List of all listener ARNs"
  value = concat(
    [aws_lb_listener.http.arn],
    var.enable_https ? [aws_lb_listener.https[0].arn] : []
  )
}

output "custom_listener_rule_arns" {
  description = "ARNs of custom listener rules"
  value       = aws_lb_listener_rule.custom_rules[*].arn
}