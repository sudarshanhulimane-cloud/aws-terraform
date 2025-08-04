output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.main.bucket_domain_name
}

output "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}

output "s3_bucket_hosted_zone_id" {
  description = "Hosted zone ID of the S3 bucket"
  value       = aws_s3_bucket.main.hosted_zone_id
}

output "ebs_volume_ids" {
  description = "List of EBS volume IDs"
  value       = aws_ebs_volume.additional[*].id
}

output "ebs_volume_arns" {
  description = "List of EBS volume ARNs"
  value       = aws_ebs_volume.additional[*].arn
}

output "ebs_volume_attachments" {
  description = "List of EBS volume attachment information"
  value = [
    for attachment in aws_volume_attachment.additional : {
      device_name = attachment.device_name
      instance_id = attachment.instance_id
      volume_id   = attachment.volume_id
    }
  ]
}