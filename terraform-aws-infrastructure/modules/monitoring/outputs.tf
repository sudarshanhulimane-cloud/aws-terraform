# Monitoring Module Outputs

output "log_group_names" {
  description = "CloudWatch log group names"
  value       = [
    aws_cloudwatch_log_group.application.name,
    aws_cloudwatch_log_group.eks.name,
    aws_cloudwatch_log_group.rds.name
  ]
}

output "alarm_arns" {
  description = "CloudWatch alarm ARNs"
  value       = concat(
    aws_cloudwatch_metric_alarm.ec2_cpu[*].arn,
    aws_cloudwatch_metric_alarm.ec2_memory[*].arn,
    aws_cloudwatch_metric_alarm.ec2_disk[*].arn,
    aws_cloudwatch_metric_alarm.eks_cpu[*].arn,
    aws_cloudwatch_metric_alarm.eks_memory[*].arn,
    aws_cloudwatch_metric_alarm.rds_cpu[*].arn,
    aws_cloudwatch_metric_alarm.rds_connections[*].arn,
    aws_cloudwatch_metric_alarm.alb_5xx[*].arn,
    aws_cloudwatch_metric_alarm.alb_target_5xx[*].arn
  )
}

output "application_log_group_arn" {
  description = "Application log group ARN"
  value       = aws_cloudwatch_log_group.application.arn
}

output "eks_log_group_arn" {
  description = "EKS log group ARN"
  value       = aws_cloudwatch_log_group.eks.arn
}

output "rds_log_group_arn" {
  description = "RDS log group ARN"
  value       = aws_cloudwatch_log_group.rds.arn
}