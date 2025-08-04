output "ec2_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = aws_iam_role.ec2_role.arn
}

output "ec2_role_name" {
  description = "Name of the EC2 IAM role"
  value       = aws_iam_role.ec2_role.name
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "ec2_instance_profile_arn" {
  description = "ARN of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_profile.arn
}

output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_cluster_role_name" {
  description = "Name of the EKS cluster IAM role"
  value       = aws_iam_role.eks_cluster_role.name
}

output "eks_node_group_role_arn" {
  description = "ARN of the EKS node group IAM role"
  value       = aws_iam_role.eks_node_role.arn
}

output "eks_node_group_role_name" {
  description = "Name of the EKS node group IAM role"
  value       = aws_iam_role.eks_node_role.name
}

output "load_balancer_controller_policy_arn" {
  description = "ARN of the Load Balancer Controller IAM policy"
  value       = var.enable_load_balancer_controller ? aws_iam_policy.load_balancer_controller_policy[0].arn : null
}

output "cluster_autoscaler_policy_arn" {
  description = "ARN of the Cluster Autoscaler IAM policy"
  value       = var.enable_cluster_autoscaler ? aws_iam_policy.cluster_autoscaler_policy[0].arn : null
}

output "ec2_s3_policy_arn" {
  description = "ARN of the EC2 S3 access policy"
  value       = aws_iam_policy.ec2_s3_policy.arn
}

output "ec2_cloudwatch_policy_arn" {
  description = "ARN of the EC2 CloudWatch policy"
  value       = aws_iam_policy.ec2_cloudwatch_policy.arn
}

output "eks_node_s3_policy_arn" {
  description = "ARN of the EKS node S3 access policy"
  value       = aws_iam_policy.eks_node_s3_policy.arn
}