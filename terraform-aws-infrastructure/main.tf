# Root Terraform configuration for AWS Infrastructure
# This file orchestrates all modules to create a complete AWS infrastructure

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# Data sources for common resources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Networking Module
module "networking" {
  source = "./modules/networking"
  
  vpc_cidr             = var.vpc_cidr
  environment          = var.environment
  project_name         = var.project_name
  availability_zones   = data.aws_availability_zones.available.names
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# Security Module
module "security" {
  source = "./modules/security"
  
  vpc_id                    = module.networking.vpc_id
  environment               = var.environment
  project_name              = var.project_name
  bastion_allowed_cidrs     = var.bastion_allowed_cidrs
  alb_allowed_cidrs         = var.alb_allowed_cidrs
  rds_allowed_cidrs         = var.rds_allowed_cidrs
  eks_worker_allowed_cidrs  = var.eks_worker_allowed_cidrs
}

# IAM Module
module "iam" {
  source = "./modules/iam"
  
  environment   = var.environment
  project_name  = var.project_name
  account_id    = data.aws_caller_identity.current.account_id
}

# Storage Module
module "storage" {
  source = "./modules/storage"
  
  environment   = var.environment
  project_name  = var.project_name
  bucket_name   = var.s3_bucket_name
}

# Database Module
module "database" {
  source = "./modules/database"
  
  vpc_id                    = module.networking.vpc_id
  private_subnet_ids        = module.networking.private_subnet_ids
  db_security_group_id      = module.security.rds_security_group_id
  environment               = var.environment
  project_name              = var.project_name
  db_engine                 = var.db_engine
  db_instance_class         = var.db_instance_class
  db_allocated_storage      = var.db_allocated_storage
  db_name                   = var.db_name
  db_username               = var.db_username
  db_password               = var.db_password
  db_multi_az               = var.db_multi_az
  db_backup_retention_period = var.db_backup_retention_period
}

# Load Balancing Module
module "load_balancing" {
  source = "./modules/load-balancing"
  
  vpc_id                    = module.networking.vpc_id
  public_subnet_ids         = module.networking.public_subnet_ids
  alb_security_group_id     = module.security.alb_security_group_id
  environment               = var.environment
  project_name              = var.project_name
  alb_internal              = var.alb_internal
  alb_enable_deletion_protection = var.alb_enable_deletion_protection
}

# Compute Module
module "compute" {
  source = "./modules/compute"
  
  vpc_id                    = module.networking.vpc_id
  public_subnet_ids         = module.networking.public_subnet_ids
  private_subnet_ids        = module.networking.private_subnet_ids
  bastion_security_group_id = module.security.bastion_security_group_id
  app_security_group_id     = module.security.app_security_group_id
  environment               = var.environment
  project_name              = var.project_name
  bastion_instance_type     = var.bastion_instance_type
  bastion_key_name          = var.bastion_key_name
  app_instance_type         = var.app_instance_type
  app_desired_capacity      = var.app_desired_capacity
  app_max_size              = var.app_max_size
  app_min_size              = var.app_min_size
  app_target_group_arns     = module.load_balancing.target_group_arns
  app_iam_role_arn          = module.iam.ec2_role_arn
}

# Containers Module
module "containers" {
  source = "./modules/containers"
  
  vpc_id                    = module.networking.vpc_id
  private_subnet_ids        = module.networking.private_subnet_ids
  eks_security_group_id     = module.security.eks_security_group_id
  environment               = var.environment
  project_name              = var.project_name
  eks_cluster_version       = var.eks_cluster_version
  eks_node_group_instance_types = var.eks_node_group_instance_types
  eks_node_group_desired_size = var.eks_node_group_desired_size
  eks_node_group_max_size   = var.eks_node_group_max_size
  eks_node_group_min_size   = var.eks_node_group_min_size
  eks_cluster_role_arn      = module.iam.eks_cluster_role_arn
  eks_node_group_role_arn   = module.iam.eks_node_group_role_arn
}

# DNS Module
module "dns" {
  source = "./modules/dns"
  
  environment               = var.environment
  project_name              = var.project_name
  domain_name               = var.domain_name
  alb_dns_name             = module.load_balancing.alb_dns_name
  alb_zone_id              = module.load_balancing.alb_zone_id
  bastion_public_ip        = module.compute.bastion_public_ip
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"
  
  environment               = var.environment
  project_name              = var.project_name
  ec2_instance_ids          = module.compute.app_instance_ids
  eks_cluster_name          = module.containers.eks_cluster_name
  rds_instance_id           = module.database.rds_instance_id
  alb_arn                   = module.load_balancing.alb_arn
}