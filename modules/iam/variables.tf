variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket for IAM policies"
  type        = string
}

variable "enable_load_balancer_controller" {
  description = "Enable AWS Load Balancer Controller IAM policy"
  type        = bool
  default     = true
}

variable "enable_cluster_autoscaler" {
  description = "Enable Cluster Autoscaler IAM policy"
  type        = bool
  default     = true
}