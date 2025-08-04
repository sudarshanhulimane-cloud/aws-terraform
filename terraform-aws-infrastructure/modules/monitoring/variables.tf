# Monitoring Module Variables

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "ec2_instance_ids" {
  description = "EC2 instance IDs for monitoring"
  type        = list(string)
  default     = []
}

variable "eks_cluster_name" {
  description = "EKS cluster name for monitoring"
  type        = string
  default     = ""
}

variable "rds_instance_id" {
  description = "RDS instance ID for monitoring"
  type        = string
  default     = ""
}

variable "alb_arn" {
  description = "ALB ARN for monitoring"
  type        = string
  default     = ""
}

variable "alarm_actions" {
  description = "Actions to take when alarms are triggered"
  type        = list(string)
  default     = []
}