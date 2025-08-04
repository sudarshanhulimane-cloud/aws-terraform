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

variable "availability_zones" {
  description = "List of availability zones for EBS volumes"
  type        = list(string)
  default     = []
}

# S3 Configuration
variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "enable_lifecycle_policy" {
  description = "Enable S3 lifecycle policy"
  type        = bool
  default     = false
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days after which noncurrent versions expire"
  type        = number
  default     = 90
}

variable "lifecycle_transitions" {
  description = "List of lifecycle transition rules"
  type = list(object({
    days          = number
    storage_class = string
  }))
  default = [
    {
      days          = 30
      storage_class = "STANDARD_IA"
    },
    {
      days          = 90
      storage_class = "GLACIER"
    }
  ]
}

# EBS Configuration
variable "enable_ebs_volumes" {
  description = "Create additional EBS volumes"
  type        = bool
  default     = false
}

variable "ebs_volume_size" {
  description = "Size of EBS volumes in GB"
  type        = number
  default     = 20
}

variable "ebs_volume_type" {
  description = "Type of EBS volumes"
  type        = string
  default     = "gp3"
}

variable "ebs_encrypted" {
  description = "Enable EBS encryption"
  type        = bool
  default     = true
}

variable "attach_to_instances" {
  description = "Attach EBS volumes to instances"
  type        = bool
  default     = false
}

variable "instance_ids" {
  description = "List of instance IDs to attach EBS volumes to"
  type        = list(string)
  default     = []
}