variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  description = "CloudWatch log retention days"
  type        = number
  default     = 7
}

variable "bastion_instance_id" {
  description = "Bastion instance ID"
  type        = string
  default     = null
}

variable "auto_scaling_group_name" {
  description = "Auto Scaling Group name"
  type        = string
  default     = ""
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix"
  type        = string
  default     = ""
}

variable "target_group_arn_suffix" {
  description = "Target Group ARN suffix"
  type        = string
  default     = ""
}

variable "rds_instance_id" {
  description = "RDS instance ID"
  type        = string
  default     = ""
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = ""
}