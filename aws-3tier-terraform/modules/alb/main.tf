# Internet-facing by design.
#tfsec:ignore:aws-elb-alb-not-public
resource "aws_lb" "this" {
  name                       = substr("${var.name}-alb", 0, 32)
  load_balancer_type         = "application"
  internal                   = false
  security_groups            = var.security_group_ids
  subnets                    = var.public_subnet_ids
  drop_invalid_header_fields = true
  enable_deletion_protection = var.deletion_protection

  tags = { Name = "${var.name}-alb" }
}

resource "aws_lb_target_group" "app" {
  name_prefix          = "app-"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "instance"
  deregistration_delay = 30

  health_check {
    path                = var.health_check_path
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  lifecycle {
    create_before_destroy = true
  }
}

# HTTP only because this demo has no domain/ACM certificate.
# Production: add an HTTPS:443 listener and redirect 80 -> 443.
#tfsec:ignore:aws-elb-http-not-used
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
