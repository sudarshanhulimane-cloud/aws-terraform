# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/application/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-app-logs"
  })
}

resource "aws_cloudwatch_log_group" "bastion" {
  name              = "/aws/ec2/${var.project_name}-${var.environment}/bastion"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-bastion-logs"
  })
}

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.project_name}-${var.environment}/cluster"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-eks-logs"
  })
}

# CloudWatch Alarms for EC2
resource "aws_cloudwatch_metric_alarm" "bastion_cpu_high" {
  count = var.bastion_instance_id != null ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-bastion-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors bastion host cpu utilization"

  dimensions = {
    InstanceId = var.bastion_instance_id
  }

  tags = var.common_tags
}

# CloudWatch Alarms for ALB
resource "aws_cloudwatch_metric_alarm" "alb_response_time" {
  count = var.alb_arn_suffix != "" ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-alb-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors ALB response time"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = var.common_tags
}

# CloudWatch Alarms for RDS
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  count = var.rds_instance_id != "" ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors RDS cpu utilization"

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  tags = var.common_tags
}