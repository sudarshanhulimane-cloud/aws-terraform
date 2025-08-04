# Random password for RDS
resource "random_password" "master_password" {
  length  = 16
  special = true
}

# Store password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "rds_password" {
  name        = "${var.project_name}-${var.environment}-rds-password"
  description = "RDS master password for ${var.project_name}-${var.environment}"

  tags = var.common_tags
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = aws_secretsmanager_secret.rds_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.master_password.result
  })
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  })
}

# DB Parameter Group
resource "aws_db_parameter_group" "main" {
  family = var.engine == "postgres" ? "postgres${split(".", var.engine_version)[0]}" : "mysql${var.engine_version}"
  name   = "${var.project_name}-${var.environment}-db-params"

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  # Default parameters based on engine
  dynamic "parameter" {
    for_each = var.engine == "postgres" ? var.postgres_default_parameters : var.mysql_default_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = var.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

# DB Option Group (for MySQL)
resource "aws_db_option_group" "main" {
  count = var.engine == "mysql" ? 1 : 0

  name                     = "${var.project_name}-${var.environment}-db-options"
  option_group_description = "Option group for ${var.project_name}-${var.environment}"
  engine_name              = var.engine
  major_engine_version     = split(".", var.engine_version)[0]

  dynamic "option" {
    for_each = var.db_options
    content {
      option_name = option.value.option_name
      
      dynamic "option_settings" {
        for_each = lookup(option.value, "option_settings", [])
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  tags = var.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-db"

  # Engine Configuration
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Storage Configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id           = var.kms_key_id

  # Database Configuration
  db_name  = var.db_name
  username = var.db_username
  password = random_password.master_password.result
  port     = var.db_port

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]
  publicly_accessible    = var.publicly_accessible

  # Availability and Backup
  multi_az               = var.multi_az
  availability_zone      = var.multi_az ? null : var.availability_zone
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  copy_tags_to_snapshot  = true

  # Parameter and Option Groups
  parameter_group_name = aws_db_parameter_group.main.name
  option_group_name    = var.engine == "mysql" ? aws_db_option_group.main[0].name : null

  # Monitoring
  monitoring_interval = var.enable_enhanced_monitoring ? var.monitoring_interval : 0
  monitoring_role_arn = var.enable_enhanced_monitoring ? aws_iam_role.rds_enhanced_monitoring[0].arn : null

  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_retention_period = var.enable_performance_insights ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id      = var.enable_performance_insights ? var.performance_insights_kms_key_id : null

  # Deletion Protection
  deletion_protection       = var.deletion_protection
  skip_final_snapshot      = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project_name}-${var.environment}-db-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Auto Minor Version Upgrade
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-db"
  })

  depends_on = [aws_db_subnet_group.main]
}

# Enhanced Monitoring IAM Role
resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = var.enable_enhanced_monitoring ? 1 : 0

  name = "${var.project_name}-${var.environment}-rds-enhanced-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count = var.enable_enhanced_monitoring ? 1 : 0

  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Read Replica (optional)
resource "aws_db_instance" "read_replica" {
  count = var.create_read_replica ? 1 : 0

  identifier = "${var.project_name}-${var.environment}-db-replica"

  replicate_source_db = aws_db_instance.main.identifier

  instance_class = var.read_replica_instance_class

  # Network Configuration
  vpc_security_group_ids = [var.rds_security_group_id]
  publicly_accessible    = var.publicly_accessible

  # Availability
  availability_zone = var.read_replica_availability_zone

  # Monitoring
  monitoring_interval = var.enable_enhanced_monitoring ? var.monitoring_interval : 0
  monitoring_role_arn = var.enable_enhanced_monitoring ? aws_iam_role.rds_enhanced_monitoring[0].arn : null

  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_retention_period = var.enable_performance_insights ? var.performance_insights_retention_period : null

  # Auto Minor Version Upgrade
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-db-replica"
  })
}