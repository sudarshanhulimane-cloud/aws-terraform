# Load Balancing Module Outputs

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB zone ID"
  value       = aws_lb.main.zone_id
}

output "target_group_arns" {
  description = "Target group ARNs"
  value       = [aws_lb_target_group.http.arn, aws_lb_target_group.https.arn]
}

output "http_target_group_arn" {
  description = "HTTP target group ARN"
  value       = aws_lb_target_group.http.arn
}

output "https_target_group_arn" {
  description = "HTTPS target group ARN"
  value       = aws_lb_target_group.https.arn
}

output "listener_arns" {
  description = "Listener ARNs"
  value       = [aws_lb_listener.http.arn, aws_lb_listener.https.arn]
}