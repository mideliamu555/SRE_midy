# ================================================
# ALB
# ================================================
resource "aws_lb" "alb" {
  internal           = false
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  name               = "sample-dev-alb"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_c.id]
  tags = {
    Name = "sample-dev-alb"
  }
  depends_on = [aws_lb_target_group.fargate01, aws_lb_target_group.fargate02]
}

# ================================================
# ALB Listener
# ================================================
resource "aws_lb_listener" "alb_80" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.fargate01.arn
    type             = "forward"
  }
  lifecycle {
    ignore_changes = [
      default_action
    ]
  }
  depends_on = [aws_lb.alb]
}

resource "aws_lb_listener" "alb_8080" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 8080
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.fargate02.arn
    type             = "forward"
  }
  lifecycle {
    ignore_changes = [
      default_action
    ]
  }
  depends_on = [aws_lb.alb]
}

# ================================================
# Target Group
# ================================================
resource "aws_lb_target_group" "fargate01" {
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  name                              = "sample-dev-fargate-tg01"
  port                              = 80
  protocol                          = "HTTP"
  tags = {
    Name = "sample-dev-fargate-tg01"
  }
  target_type = "ip"
  vpc_id      = aws_vpc.this.id
}

resource "aws_lb_target_group" "fargate02" {
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  name                              = "sample-dev-fargate-tg02"
  port                              = 80
  protocol                          = "HTTP"
  tags = {
    Name = "sample-dev-fargate-tg02"
  }
  target_type = "ip"
  vpc_id      = aws_vpc.this.id
}