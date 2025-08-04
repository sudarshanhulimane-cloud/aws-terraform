# Storage Module Outputs

output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.main.bucket
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.main.arn
}

output "bucket_id" {
  description = "S3 bucket ID"
  value       = aws_s3_bucket.main.id
}

output "bucket_region" {
  description = "S3 bucket region"
  value       = aws_s3_bucket.main.region
}