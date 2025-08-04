output "cloudwatch_log_group_names" {
  description = "Names of CloudWatch log groups"
  value = [
    aws_cloudwatch_log_group.application.name,
    aws_cloudwatch_log_group.bastion.name,
    aws_cloudwatch_log_group.eks.name
  ]
}

output "cloudwatch_log_group_arns" {
  description = "ARNs of CloudWatch log groups"
  value = [
    aws_cloudwatch_log_group.application.arn,
    aws_cloudwatch_log_group.bastion.arn,
    aws_cloudwatch_log_group.eks.arn
  ]
}

output "alarm_names" {
  description = "Names of CloudWatch alarms"
  value = compact([
    var.bastion_instance_id != null ? aws_cloudwatch_metric_alarm.bastion_cpu_high[0].alarm_name : "",
    var.alb_arn_suffix != "" ? aws_cloudwatch_metric_alarm.alb_response_time[0].alarm_name : "",
    var.rds_instance_id != "" ? aws_cloudwatch_metric_alarm.rds_cpu_high[0].alarm_name : ""
  ])
}