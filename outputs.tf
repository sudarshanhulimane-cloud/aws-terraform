# Networking Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.networking.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.networking.internet_gateway_id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = module.networking.nat_gateway_id
}

# Security Outputs
output "bastion_security_group_id" {
  description = "ID of the bastion host security group"
  value       = module.security.bastion_security_group_id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = module.security.alb_security_group_id
}

output "eks_security_group_id" {
  description = "ID of the EKS security group"
  value       = module.security.eks_security_group_id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = module.security.rds_security_group_id
}

# Compute Outputs
output "bastion_host_id" {
  description = "ID of the bastion host"
  value       = module.compute.bastion_host_id
}

output "bastion_host_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.compute.bastion_host_public_ip
}

output "bastion_host_private_ip" {
  description = "Private IP of the bastion host"
  value       = module.compute.bastion_host_private_ip
}

output "auto_scaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = var.enable_auto_scaling ? module.compute.auto_scaling_group_arn : null
}

# Load Balancer Outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.load_balancer.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.load_balancer.alb_zone_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.load_balancer.alb_arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.load_balancer.target_group_arn
}

# EKS Outputs
output "eks_cluster_id" {
  description = "ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "eks_cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "eks_node_group_arn" {
  description = "ARN of the EKS node group"
  value       = module.eks.node_group_arn
}

# Storage Outputs
output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = module.storage.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.storage.s3_bucket_arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = module.storage.s3_bucket_domain_name
}

output "ebs_volume_ids" {
  description = "IDs of the EBS volumes"
  value       = var.enable_ebs_volumes ? module.storage.ebs_volume_ids : []
}

# Database Outputs
output "rds_instance_id" {
  description = "ID of the RDS instance"
  value       = module.database.rds_instance_id
}

output "rds_instance_arn" {
  description = "ARN of the RDS instance"
  value       = module.database.rds_instance_arn
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.database.rds_endpoint
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.database.rds_port
}

# DNS Outputs
output "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = var.create_route53_zone ? module.dns.route53_zone_id : null
}

output "route53_name_servers" {
  description = "Route 53 name servers"
  value       = var.create_route53_zone ? module.dns.route53_name_servers : []
}

# IAM Outputs
output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = module.iam.ec2_instance_profile_name
}

output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = module.iam.eks_cluster_role_arn
}

output "eks_node_group_role_arn" {
  description = "ARN of the EKS node group IAM role"
  value       = module.iam.eks_node_group_role_arn
}

# Monitoring Outputs
output "cloudwatch_log_group_names" {
  description = "Names of CloudWatch log groups"
  value       = module.monitoring.cloudwatch_log_group_names
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.cloudfront_invalidator.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.cloudfront_invalidator.arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for the Lambda function"
  value       = aws_cloudwatch_log_group.lambda_log_group.name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket configured for notifications"
  value       = data.aws_s3_bucket.existing_bucket.bucket
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution being invalidated"
  value       = data.aws_cloudfront_distribution.existing_distribution.id
}