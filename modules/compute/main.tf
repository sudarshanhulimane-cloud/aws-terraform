# Data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Bastion Host Launch Template
resource "aws_launch_template" "bastion" {
  name_prefix   = "${var.project_name}-${var.environment}-bastion-"
  image_id      = var.bastion_ami_id != "" ? var.bastion_ami_id : data.aws_ami.amazon_linux.id
  instance_type = var.bastion_instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.bastion_security_group_id]

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  user_data = base64encode(templatefile("${path.module}/user_data/bastion_user_data.sh", {
    project_name = var.project_name
    environment  = var.environment
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.project_name}-${var.environment}-bastion"
      Type = "Bastion"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Bastion Host Instance
resource "aws_instance" "bastion" {
  launch_template {
    id      = aws_launch_template.bastion.id
    version = "$Latest"
  }

  subnet_id = var.public_subnet_ids[0]

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-bastion"
    Type = "Bastion"
  })
}

# Application Server Launch Template
resource "aws_launch_template" "app_server" {
  count = var.enable_auto_scaling ? 1 : 0

  name_prefix   = "${var.project_name}-${var.environment}-app-server-"
  image_id      = var.app_server_ami_id != "" ? var.app_server_ami_id : data.aws_ami.amazon_linux.id
  instance_type = var.app_instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.app_server_security_group_id]

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  user_data = base64encode(templatefile("${path.module}/user_data/app_server_user_data.sh", {
    project_name = var.project_name
    environment  = var.environment
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.project_name}-${var.environment}-app-server"
      Type = "Application"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_server" {
  count = var.enable_auto_scaling ? 1 : 0

  name                = "${var.project_name}-${var.environment}-app-server-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = var.target_group_arns
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  launch_template {
    id      = aws_launch_template.app_server[0].id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(var.common_tags, {
      Name = "${var.project_name}-${var.environment}-app-server-asg"
      Type = "AutoScalingGroup"
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}

# Auto Scaling Policies
resource "aws_autoscaling_policy" "scale_up" {
  count = var.enable_auto_scaling ? 1 : 0

  name                   = "${var.project_name}-${var.environment}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_server[0].name
}

resource "aws_autoscaling_policy" "scale_down" {
  count = var.enable_auto_scaling ? 1 : 0

  name                   = "${var.project_name}-${var.environment}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_server[0].name
}

# CloudWatch Alarms for Auto Scaling
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count = var.enable_auto_scaling ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_server[0].name
  }

  alarm_actions = [aws_autoscaling_policy.scale_up[0].arn]

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  count = var.enable_auto_scaling ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"
  alarm_description   = "This metric monitors ec2 cpu utilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_server[0].name
  }

  alarm_actions = [aws_autoscaling_policy.scale_down[0].arn]

  tags = var.common_tags
}