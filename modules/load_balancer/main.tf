# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  # Access logs
  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-alb"
  })
}

# Target Group for HTTP traffic
resource "aws_lb_target_group" "http" {
  name     = "${var.project_name}-${var.environment}-http-tg"
  port     = var.target_port
  protocol = var.target_protocol
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  # Connection draining
  deregistration_delay = var.deregistration_delay

  # Stickiness
  dynamic "stickiness" {
    for_each = var.enable_stickiness ? [1] : []
    content {
      type            = var.stickiness_type
      cookie_duration = var.stickiness_cookie_duration
      enabled         = true
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-http-tg"
  })
}

# Target Group for HTTPS traffic (if different from HTTP)
resource "aws_lb_target_group" "https" {
  count = var.create_https_target_group ? 1 : 0

  name     = "${var.project_name}-${var.environment}-https-tg"
  port     = var.https_target_port
  protocol = var.target_protocol
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  deregistration_delay = var.deregistration_delay

  dynamic "stickiness" {
    for_each = var.enable_stickiness ? [1] : []
    content {
      type            = var.stickiness_type
      cookie_duration = var.stickiness_cookie_duration
      enabled         = true
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-https-tg"
  })
}

# HTTP Listener (redirect to HTTPS or serve HTTP)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = var.redirect_http_to_https ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = var.redirect_http_to_https ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.http.arn
    }
  }

  tags = var.common_tags
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  count = var.enable_https ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = var.create_https_target_group ? aws_lb_target_group.https[0].arn : aws_lb_target_group.http.arn
  }

  tags = var.common_tags
}

# Custom Listener Rules
resource "aws_lb_listener_rule" "custom_rules" {
  count = length(var.custom_listener_rules)

  listener_arn = var.custom_listener_rules[count.index].https_rule && var.enable_https ? aws_lb_listener.https[0].arn : aws_lb_listener.http.arn
  priority     = var.custom_listener_rules[count.index].priority

  action {
    type             = var.custom_listener_rules[count.index].action_type
    target_group_arn = var.custom_listener_rules[count.index].target_group_arn
  }

  dynamic "condition" {
    for_each = var.custom_listener_rules[count.index].conditions
    content {
      dynamic "path_pattern" {
        for_each = lookup(condition.value, "path_pattern", null) != null ? [condition.value.path_pattern] : []
        content {
          values = path_pattern.value
        }
      }

      dynamic "host_header" {
        for_each = lookup(condition.value, "host_header", null) != null ? [condition.value.host_header] : []
        content {
          values = host_header.value
        }
      }

      dynamic "http_header" {
        for_each = lookup(condition.value, "http_header", null) != null ? [condition.value.http_header] : []
        content {
          http_header_name = http_header.value.name
          values           = http_header.value.values
        }
      }
    }
  }

  tags = var.common_tags
}

# WAF Web ACL Association (optional)
resource "aws_wafv2_web_acl_association" "main" {
  count = var.waf_web_acl_arn != "" ? 1 : 0

  resource_arn = aws_lb.main.arn
  web_acl_arn  = var.waf_web_acl_arn
}