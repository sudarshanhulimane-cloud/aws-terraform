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

# Network Configuration
variable "public_subnet_ids" {
  description = "List of public subnet IDs for bastion host"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for application servers"
  type        = list(string)
}

# Security Groups
variable "bastion_security_group_id" {
  description = "Security group ID for bastion host"
  type        = string
}

variable "app_server_security_group_id" {
  description = "Security group ID for application servers"
  type        = string
}

# IAM
variable "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2 instances"
  type        = string
}

# Key Pair
variable "key_name" {
  description = "Name of the AWS key pair for SSH access"
  type        = string
  default     = ""
}

# Bastion Host Configuration
variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "bastion_ami_id" {
  description = "AMI ID for bastion host (leave empty for latest Amazon Linux 2)"
  type        = string
  default     = ""
}

# Application Server Configuration
variable "app_instance_type" {
  description = "Instance type for application servers"
  type        = string
  default     = "t3.medium"
}

variable "app_server_ami_id" {
  description = "AMI ID for application servers (leave empty for latest Amazon Linux 2)"
  type        = string
  default     = ""
}

# Auto Scaling Configuration
variable "enable_auto_scaling" {
  description = "Enable Auto Scaling Group for application servers"
  type        = bool
  default     = false
}

variable "asg_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "target_group_arns" {
  description = "List of target group ARNs for Auto Scaling Group"
  type        = list(string)
  default     = []
}

# Monitoring
variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false
}