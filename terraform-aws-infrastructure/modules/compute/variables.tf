# Compute Module Variables

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "bastion_security_group_id" {
  description = "Bastion security group ID"
  type        = string
}

variable "app_security_group_id" {
  description = "Application security group ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "bastion_instance_type" {
  description = "EC2 instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "bastion_key_name" {
  description = "SSH key pair name for bastion host"
  type        = string
  default     = "bastion-key"
}

variable "bastion_iam_role_arn" {
  description = "IAM role ARN for bastion host"
  type        = string
  default     = ""
}

variable "app_instance_type" {
  description = "EC2 instance type for application servers"
  type        = string
  default     = "t3.small"
}

variable "app_desired_capacity" {
  description = "Desired capacity for Auto Scaling Group"
  type        = number
  default     = 2
}

variable "app_max_size" {
  description = "Maximum size for Auto Scaling Group"
  type        = number
  default     = 4
}

variable "app_min_size" {
  description = "Minimum size for Auto Scaling Group"
  type        = number
  default     = 1
}

variable "app_target_group_arns" {
  description = "Target group ARNs for Auto Scaling Group"
  type        = list(string)
  default     = []
}

variable "app_iam_role_arn" {
  description = "IAM role ARN for application instances"
  type        = string
  default     = ""
}