# Traffic chain: Internet -> ALB -> App -> DB. Each hop references the previous SG, never a CIDR.

resource "aws_security_group" "alb" {
  name_prefix = "${var.name}-alb-"
  description = "ALB: HTTP from the internet"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name}-alb-sg" }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "app" {
  name_prefix = "${var.name}-app-"
  description = "App tier: HTTP from the ALB only"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name}-app-sg" }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "db" {
  name_prefix = "${var.name}-db-"
  description = "DB tier: database port from the app tier only"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name}-db-sg" }

  lifecycle {
    create_before_destroy = true
  }
}

# ALB is intentionally internet-facing on port 80.
#tfsec:ignore:aws-ec2-no-public-ingress-sgr
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb.id
  description                  = "ALB to app instances"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "HTTP from ALB SG"
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

# Needed for SSM agent + package installs via NAT. Tighten with VPC endpoints later.
#tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_vpc_security_group_egress_rule" "app_all_out" {
  security_group_id = aws_security_group.app.id
  description       = "Outbound via NAT (SSM, dnf)"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "DB port from app SG"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
}
