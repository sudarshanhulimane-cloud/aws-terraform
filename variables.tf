# General Configuration
variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "aws-infrastructure"
}

# Networking Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

# Security Configuration
variable "bastion_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH to bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = ""
}

# Compute Configuration
variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "app_instance_type" {
  description = "Instance type for application servers"
  type        = string
  default     = "t3.medium"
}

variable "bastion_ami_id" {
  description = "AMI ID for bastion host (leave empty for latest Amazon Linux 2)"
  type        = string
  default     = ""
}

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

# EKS Configuration
variable "eks_cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "eks_node_instance_types" {
  description = "Instance types for EKS worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_group_min_size" {
  description = "Minimum size of EKS node group"
  type        = number
  default     = 1
}

variable "eks_node_group_max_size" {
  description = "Maximum size of EKS node group"
  type        = number
  default     = 3
}

variable "eks_node_group_desired_size" {
  description = "Desired size of EKS node group"
  type        = number
  default     = 2
}

# Database Configuration
variable "rds_engine" {
  description = "RDS engine (postgres or mysql)"
  type        = string
  default     = "postgres"
  validation {
    condition     = contains(["postgres", "mysql"], var.rds_engine)
    error_message = "RDS engine must be either 'postgres' or 'mysql'."
  }
}

variable "rds_engine_version" {
  description = "RDS engine version"
  type        = string
  default     = "15.4"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "rds_multi_az" {
  description = "Enable Multi-AZ deployment for RDS"
  type        = bool
  default     = false
}

variable "rds_db_name" {
  description = "Name of the database"
  type        = string
  default     = "appdb"
}

variable "rds_username" {
  description = "Master username for RDS"
  type        = string
  default     = "admin"
}

# Storage Configuration
variable "s3_versioning_enabled" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "enable_ebs_volumes" {
  description = "Create additional EBS volumes"
  type        = bool
  default     = false
}

variable "ebs_volume_size" {
  description = "Size of additional EBS volumes in GB"
  type        = number
  default     = 20
}

# DNS Configuration
variable "domain_name" {
  description = "Domain name for Route 53 hosted zone"
  type        = string
  default     = ""
}

variable "create_route53_zone" {
  description = "Create Route 53 hosted zone"
  type        = bool
  default     = false
}

# Monitoring Configuration
variable "cloudwatch_log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 7
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false
}