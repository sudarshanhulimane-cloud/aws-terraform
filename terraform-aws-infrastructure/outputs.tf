# Root outputs for AWS Infrastructure

# Networking Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.networking.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "nat_gateway_ips" {
  description = "NAT Gateway public IPs"
  value       = module.networking.nat_gateway_ips
}

# Security Outputs
output "bastion_security_group_id" {
  description = "Bastion host security group ID"
  value       = module.security.bastion_security_group_id
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = module.security.alb_security_group_id
}

output "app_security_group_id" {
  description = "Application security group ID"
  value       = module.security.app_security_group_id
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = module.security.rds_security_group_id
}

output "eks_security_group_id" {
  description = "EKS security group ID"
  value       = module.security.eks_security_group_id
}

# Storage Outputs
output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.storage.bucket_name
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.storage.bucket_arn
}

# Database Outputs
output "rds_instance_id" {
  description = "RDS instance ID"
  value       = module.database.instance_id
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.database.endpoint
}

output "rds_port" {
  description = "RDS port"
  value       = module.database.port
}

# Load Balancer Outputs
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.load_balancing.alb_dns_name
}

output "alb_zone_id" {
  description = "ALB zone ID"
  value       = module.load_balancing.alb_zone_id
}

output "alb_arn" {
  description = "ALB ARN"
  value       = module.load_balancing.alb_arn
}

# Compute Outputs
output "bastion_public_ip" {
  description = "Bastion host public IP"
  value       = module.compute.bastion_public_ip
}

output "app_instance_ids" {
  description = "Application instance IDs"
  value       = module.compute.app_instance_ids
}

output "app_asg_name" {
  description = "Auto Scaling Group name"
  value       = module.compute.app_asg_name
}

# Container Outputs
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.containers.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.containers.cluster_endpoint
}

output "eks_cluster_version" {
  description = "EKS cluster version"
  value       = module.containers.cluster_version
}

output "eks_node_group_arns" {
  description = "EKS node group ARNs"
  value       = module.containers.node_group_arns
}

# DNS Outputs
output "hosted_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = module.dns.hosted_zone_id
}

output "alb_dns_record" {
  description = "ALB DNS record"
  value       = module.dns.alb_dns_record
}

output "bastion_dns_record" {
  description = "Bastion DNS record"
  value       = module.dns.bastion_dns_record
}

# IAM Outputs
output "ec2_role_arn" {
  description = "EC2 IAM role ARN"
  value       = module.iam.ec2_role_arn
}

output "eks_cluster_role_arn" {
  description = "EKS cluster IAM role ARN"
  value       = module.iam.eks_cluster_role_arn
}

output "eks_node_group_role_arn" {
  description = "EKS node group IAM role ARN"
  value       = module.iam.eks_node_group_role_arn
}

# Monitoring Outputs
output "cloudwatch_log_groups" {
  description = "CloudWatch log group names"
  value       = module.monitoring.log_group_names
}

output "cloudwatch_alarm_arns" {
  description = "CloudWatch alarm ARNs"
  value       = module.monitoring.alarm_arns
}