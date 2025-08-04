output "bastion_security_group_id" {
  description = "ID of the bastion host security group"
  value       = aws_security_group.bastion.id
}

output "bastion_security_group_arn" {
  description = "ARN of the bastion host security group"
  value       = aws_security_group.bastion.arn
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "alb_security_group_arn" {
  description = "ARN of the ALB security group"
  value       = aws_security_group.alb.arn
}

output "app_server_security_group_id" {
  description = "ID of the application server security group"
  value       = aws_security_group.app_server.id
}

output "app_server_security_group_arn" {
  description = "ARN of the application server security group"
  value       = aws_security_group.app_server.arn
}

output "eks_cluster_security_group_id" {
  description = "ID of the EKS cluster security group"
  value       = aws_security_group.eks_cluster.id
}

output "eks_cluster_security_group_arn" {
  description = "ARN of the EKS cluster security group"
  value       = aws_security_group.eks_cluster.arn
}

output "eks_nodes_security_group_id" {
  description = "ID of the EKS nodes security group"
  value       = aws_security_group.eks_nodes.id
}

output "eks_nodes_security_group_arn" {
  description = "ARN of the EKS nodes security group"
  value       = aws_security_group.eks_nodes.arn
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "rds_security_group_arn" {
  description = "ARN of the RDS security group"
  value       = aws_security_group.rds.arn
}

# For backward compatibility, alias to match root outputs
output "eks_security_group_id" {
  description = "ID of the EKS cluster security group (alias)"
  value       = aws_security_group.eks_cluster.id
}