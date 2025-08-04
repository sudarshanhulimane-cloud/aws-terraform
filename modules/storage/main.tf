# Random string for unique bucket naming
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket
resource "aws_s3_bucket" "main" {
  bucket = "${var.project_name}-${var.environment}-${random_string.bucket_suffix.result}"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-s3-bucket"
  })
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# S3 Bucket Server-side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count = var.enable_lifecycle_policy ? 1 : 0

  bucket = aws_s3_bucket.main.id

  rule {
    id     = "lifecycle"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }

    dynamic "transition" {
      for_each = var.lifecycle_transitions
      content {
        days          = transition.value.days
        storage_class = transition.value.storage_class
      }
    }
  }
}

# EBS Volumes (optional)
resource "aws_ebs_volume" "additional" {
  count = var.enable_ebs_volumes ? length(var.availability_zones) : 0

  availability_zone = var.availability_zones[count.index]
  size              = var.ebs_volume_size
  type              = var.ebs_volume_type
  encrypted         = var.ebs_encrypted

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-ebs-volume-${count.index + 1}"
  })
}

# EBS Volume Attachments (requires EC2 instances to exist)
resource "aws_volume_attachment" "additional" {
  count = var.enable_ebs_volumes && var.attach_to_instances ? length(var.instance_ids) : 0

  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.additional[count.index].id
  instance_id = var.instance_ids[count.index]
}