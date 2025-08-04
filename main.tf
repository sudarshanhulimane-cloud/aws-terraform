# Local values for common tags and naming
locals {
  common_tags = {
    Environment   = var.environment
    Project       = var.project_name
    ManagedBy     = "Terraform"
    CreatedDate   = formatdate("YYYY-MM-DD", timestamp())
  }
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones
  common_tags       = local.common_tags
}

# IAM Module (created first as other modules depend on it)
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags
  
  # Will be created by storage module, using placeholder
  s3_bucket_arn = "arn:aws:s3:::${var.project_name}-${var.environment}-placeholder"
}

# Storage Module
module "storage" {
  source = "./modules/storage"

  project_name       = var.project_name
  environment        = var.environment
  availability_zones = var.availability_zones
  common_tags       = local.common_tags

  enable_versioning     = var.s3_versioning_enabled
  enable_ebs_volumes    = var.enable_ebs_volumes
  ebs_volume_size      = var.ebs_volume_size
}

# Security Module
module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id
  vpc_cidr     = module.networking.vpc_cidr
  common_tags  = local.common_tags

  bastion_allowed_cidrs = var.bastion_allowed_cidrs
  rds_port             = var.rds_engine == "postgres" ? 5432 : 3306
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags

  # Network Configuration
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids

  # Security Groups
  bastion_security_group_id     = module.security.bastion_security_group_id
  app_server_security_group_id  = module.security.app_server_security_group_id

  # IAM
  iam_instance_profile_name = module.iam.ec2_instance_profile_name

  # Instance Configuration
  key_name                = var.ssh_key_name
  bastion_instance_type   = var.bastion_instance_type
  bastion_ami_id         = var.bastion_ami_id
  app_instance_type      = var.app_instance_type

  # Auto Scaling
  enable_auto_scaling  = var.enable_auto_scaling
  asg_min_size        = var.asg_min_size
  asg_max_size        = var.asg_max_size
  asg_desired_capacity = var.asg_desired_capacity
  target_group_arns   = var.enable_auto_scaling ? [module.load_balancer.target_group_arn] : []

  # Monitoring
  enable_detailed_monitoring = var.enable_detailed_monitoring
}

# Load Balancer Module
module "load_balancer" {
  source = "./modules/load_balancer"

  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags

  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.public_subnet_ids

  alb_security_group_id = module.security.alb_security_group_id

  # Target Group Configuration
  target_port = 8080

  # HTTPS Configuration (requires certificate ARN)
  enable_https = false  # Set to true when certificate is available
  # certificate_arn = "arn:aws:acm:region:account:certificate/certificate-id"
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags

  # Network Configuration
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids

  # Security Groups
  eks_cluster_security_group_id = module.security.eks_cluster_security_group_id
  eks_nodes_security_group_id   = module.security.eks_nodes_security_group_id

  # IAM Roles
  cluster_role_arn    = module.iam.eks_cluster_role_arn
  node_group_role_arn = module.iam.eks_node_group_role_arn

  # EKS Configuration
  cluster_version       = var.eks_cluster_version
  node_instance_types   = var.eks_node_instance_types
  node_group_min_size   = var.eks_node_group_min_size
  node_group_max_size   = var.eks_node_group_max_size
  node_group_desired_size = var.eks_node_group_desired_size
}

# Database Module
module "database" {
  source = "./modules/database"

  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags

  # Network Configuration
  private_subnet_ids    = module.networking.private_subnet_ids
  rds_security_group_id = module.security.rds_security_group_id

  # Database Configuration
  engine         = var.rds_engine
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class
  
  allocated_storage = var.rds_allocated_storage
  multi_az         = var.rds_multi_az
  
  db_name    = var.rds_db_name
  db_username = var.rds_username
}

# DNS Module (optional)
module "dns" {
  count  = var.create_route53_zone ? 1 : 0
  source = "./modules/dns"

  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags

  domain_name = var.domain_name
  
  # ALB DNS record
  alb_dns_name    = module.load_balancer.alb_dns_name
  alb_zone_id     = module.load_balancer.alb_zone_id
  
  # Bastion DNS record
  bastion_public_ip = module.compute.bastion_host_public_ip
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags

  # CloudWatch Configuration
  log_retention_days = var.cloudwatch_log_retention_days

  # Resources to monitor
  bastion_instance_id      = module.compute.bastion_host_id
  auto_scaling_group_name  = var.enable_auto_scaling ? module.compute.auto_scaling_group_name : null
  alb_arn_suffix          = split("/", module.load_balancer.alb_arn)[1]
  target_group_arn_suffix = split("/", module.load_balancer.target_group_arn)[1]
  rds_instance_id         = module.database.rds_instance_id
  eks_cluster_name        = module.eks.cluster_id
}

# Data sources to reference existing resources
data "aws_s3_bucket" "existing_bucket" {
  bucket = var.bucket_name
}

data "aws_cloudfront_distribution" "existing_distribution" {
  id = var.cloudfront_distribution_id
}

# IAM role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for CloudFront invalidation and CloudWatch logging
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.lambda_function_name}-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation"
        ]
        Resource = data.aws_cloudfront_distribution.existing_distribution.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# CloudWatch log group for Lambda
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

# Lambda function
resource "aws_lambda_function" "cache_invalidator" {
  filename         = "lambda_function.zip"
  function_name    = var.lambda_function_name
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = var.lambda_runtime
  timeout         = 30

  environment {
    variables = {
      CLOUDFRONT_DISTRIBUTION_ID = var.cloudfront_distribution_id
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda_policy,
    aws_cloudwatch_log_group.lambda_log_group
  ]
}

# Lambda permission to allow S3 to invoke the function
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cache_invalidator.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.existing_bucket.arn
}

# S3 bucket notification configuration
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.aws_s3_bucket.existing_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.cache_invalidator.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}