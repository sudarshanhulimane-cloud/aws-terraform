# Security Group for Bastion Host
resource "aws_security_group" "bastion" {
  name_prefix = "${var.project_name}-${var.environment}-bastion-"
  vpc_id      = var.vpc_id

  # SSH inbound from allowed CIDRs
  dynamic "ingress" {
    for_each = var.bastion_allowed_cidrs
    content {
      description = "SSH from ${ingress.value}"
      from_port   = var.ssh_port
      to_port     = var.ssh_port
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-bastion-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for Application Load Balancer
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-${var.environment}-alb-"
  vpc_id      = var.vpc_id

  # HTTP inbound
  dynamic "ingress" {
    for_each = var.alb_http_ports
    content {
      description = "HTTP on port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.alb_allowed_cidrs
    }
  }

  # HTTPS inbound
  dynamic "ingress" {
    for_each = var.alb_https_ports
    content {
      description = "HTTPS on port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.alb_allowed_cidrs
    }
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for Application Servers
resource "aws_security_group" "app_server" {
  name_prefix = "${var.project_name}-${var.environment}-app-server-"
  vpc_id      = var.vpc_id

  # HTTP from ALB
  ingress {
    description     = "HTTP from ALB"
    from_port       = var.app_server_port
    to_port         = var.app_server_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # SSH from bastion
  ingress {
    description     = "SSH from bastion"
    from_port       = var.ssh_port
    to_port         = var.ssh_port
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # Custom application ports
  dynamic "ingress" {
    for_each = var.app_server_custom_ports
    content {
      description     = "Custom port ${ingress.value}"
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.alb.id]
    }
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-app-server-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for EKS Cluster
resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.project_name}-${var.environment}-eks-cluster-"
  vpc_id      = var.vpc_id

  # HTTPS API server
  ingress {
    description = "HTTPS API server"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-eks-cluster-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for EKS Worker Nodes
resource "aws_security_group" "eks_nodes" {
  name_prefix = "${var.project_name}-${var.environment}-eks-nodes-"
  vpc_id      = var.vpc_id

  # Self-referencing rule for node-to-node communication
  ingress {
    description = "Node-to-node communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # From EKS cluster
  ingress {
    description     = "From EKS cluster"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  # HTTPS from EKS cluster
  ingress {
    description     = "HTTPS from EKS cluster"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  # SSH from bastion (optional)
  dynamic "ingress" {
    for_each = var.enable_eks_ssh_access ? [1] : []
    content {
      description     = "SSH from bastion"
      from_port       = var.ssh_port
      to_port         = var.ssh_port
      protocol        = "tcp"
      security_groups = [aws_security_group.bastion.id]
    }
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-eks-nodes-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-${var.environment}-rds-"
  vpc_id      = var.vpc_id

  # Database port from application servers
  ingress {
    description     = "Database from app servers"
    from_port       = var.rds_port
    to_port         = var.rds_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app_server.id]
  }

  # Database port from EKS nodes
  ingress {
    description     = "Database from EKS nodes"
    from_port       = var.rds_port
    to_port         = var.rds_port
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }

  # Database port from bastion (for management)
  dynamic "ingress" {
    for_each = var.enable_rds_bastion_access ? [1] : []
    content {
      description     = "Database from bastion"
      from_port       = var.rds_port
      to_port         = var.rds_port
      protocol        = "tcp"
      security_groups = [aws_security_group.bastion.id]
    }
  }

  # Custom database ports
  dynamic "ingress" {
    for_each = var.rds_custom_ports
    content {
      description     = "Custom database port ${ingress.value}"
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.app_server.id, aws_security_group.eks_nodes.id]
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-rds-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Additional Security Group Rules for EKS Cluster to communicate with nodes
resource "aws_security_group_rule" "eks_cluster_to_nodes" {
  description              = "EKS cluster to nodes"
  type                     = "egress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_cluster.id
}

resource "aws_security_group_rule" "eks_cluster_to_nodes_https" {
  description              = "EKS cluster to nodes HTTPS"
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_cluster.id
}