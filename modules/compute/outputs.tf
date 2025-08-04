output "bastion_host_id" {
  description = "ID of the bastion host"
  value       = aws_instance.bastion.id
}

output "bastion_host_arn" {
  description = "ARN of the bastion host"
  value       = aws_instance.bastion.arn
}

output "bastion_host_public_ip" {
  description = "Public IP address of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_host_private_ip" {
  description = "Private IP address of the bastion host"
  value       = aws_instance.bastion.private_ip
}

output "bastion_host_public_dns" {
  description = "Public DNS name of the bastion host"
  value       = aws_instance.bastion.public_dns
}

output "bastion_launch_template_id" {
  description = "ID of the bastion host launch template"
  value       = aws_launch_template.bastion.id
}

output "app_server_launch_template_id" {
  description = "ID of the application server launch template"
  value       = var.enable_auto_scaling ? aws_launch_template.app_server[0].id : null
}

output "auto_scaling_group_id" {
  description = "ID of the Auto Scaling Group"
  value       = var.enable_auto_scaling ? aws_autoscaling_group.app_server[0].id : null
}

output "auto_scaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = var.enable_auto_scaling ? aws_autoscaling_group.app_server[0].arn : null
}

output "auto_scaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = var.enable_auto_scaling ? aws_autoscaling_group.app_server[0].name : null
}

output "scale_up_policy_arn" {
  description = "ARN of the scale up policy"
  value       = var.enable_auto_scaling ? aws_autoscaling_policy.scale_up[0].arn : null
}

output "scale_down_policy_arn" {
  description = "ARN of the scale down policy"
  value       = var.enable_auto_scaling ? aws_autoscaling_policy.scale_down[0].arn : null
}

output "cpu_high_alarm_arn" {
  description = "ARN of the CPU high alarm"
  value       = var.enable_auto_scaling ? aws_cloudwatch_metric_alarm.cpu_high[0].arn : null
}

output "cpu_low_alarm_arn" {
  description = "ARN of the CPU low alarm"
  value       = var.enable_auto_scaling ? aws_cloudwatch_metric_alarm.cpu_low[0].arn : null
}