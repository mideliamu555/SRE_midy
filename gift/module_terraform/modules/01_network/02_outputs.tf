# ================================================
# Output Variables
# ================================================
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "subnet" {
  description = "Map of subnet IDs"
  value = {
    public_a_id     = aws_subnet.public_a.id
    public_c_id     = aws_subnet.public_c.id
    protected_a_id  = aws_subnet.protected_a.id
    protected_c_id  = aws_subnet.protected_c.id
  }
}

output "security_group" {
  description = "Map of security group IDs"
  value = {
    fargate_ecs_task_id = aws_security_group.fargate_ecs_task.id
  }
}

output "target_group" {
  description = "Map of target group information"
  value = {
    fargate01_arn  = aws_lb_target_group.fargate01.arn
    fargate01_name = aws_lb_target_group.fargate01.name
    fargate02_arn  = aws_lb_target_group.fargate02.arn
    fargate02_name = aws_lb_target_group.fargate02.name
  }
}

output "alb_listener" {
  description = "Map of ALB listener ARNs"
  value = {
    alb_80_arn   = aws_lb_listener.alb_80.arn
    alb_8080_arn = aws_lb_listener.alb_8080.arn
  }
}