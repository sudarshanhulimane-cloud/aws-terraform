variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

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

# Bastion Security Group Variables
variable "bastion_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH to bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_port" {
  description = "SSH port"
  type        = number
  default     = 22
}

# ALB Security Group Variables
variable "alb_allowed_cidrs" {
  description = "CIDR blocks allowed to access ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_http_ports" {
  description = "HTTP ports for ALB"
  type        = list(number)
  default     = [80]
}

variable "alb_https_ports" {
  description = "HTTPS ports for ALB"
  type        = list(number)
  default     = [443]
}

# Application Server Security Group Variables
variable "app_server_port" {
  description = "Primary application server port"
  type        = number
  default     = 8080
}

variable "app_server_custom_ports" {
  description = "Additional custom ports for application servers"
  type        = list(number)
  default     = []
}

# EKS Security Group Variables
variable "enable_eks_ssh_access" {
  description = "Enable SSH access to EKS nodes from bastion"
  type        = bool
  default     = false
}

# RDS Security Group Variables
variable "rds_port" {
  description = "RDS database port"
  type        = number
  default     = 5432
}

variable "rds_custom_ports" {
  description = "Additional custom ports for RDS"
  type        = list(number)
  default     = []
}

variable "enable_rds_bastion_access" {
  description = "Enable database access from bastion host"
  type        = bool
  default     = true
}