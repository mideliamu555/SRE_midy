# ================================================
# ALB Security Group
# ================================================
resource "aws_security_group" "alb" {
  description = "sample-dev-alb-sg"
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "any"
    from_port        = 443
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 443
    }, {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "any"
    from_port        = 80
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 80
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "any"
      from_port        = 8080
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 8080
    }
  ]
  name = "sample-dev-alb-sg"
  tags = {
    Name = "sample-dev-alb-sg"
  }
  vpc_id = aws_vpc.this.id
}


# ================================================
# ECS Fargate Secrutiy Group
# ================================================
resource "aws_security_group" "fargate_ecs_task" {
  description = "sample-dev-fargate-ecs-task-sg"
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress = [{
    cidr_blocks      = []
    description      = "sample-dev-alb-sg"
    from_port        = 80
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb.id]
    self             = false
    to_port          = 80
  }]
  name = "sample-dev-fargate-ecs-task-sg"
  tags = {
    Name = "sample-dev-fargate-ecs-task-sg"
  }
  vpc_id = aws_vpc.this.id
}


# ================================================
# RDS Security Group
# ================================================
resource "aws_security_group" "rds" {
  description = "sample-dev-rds-sg"
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress = [{
    cidr_blocks      = []
    description      = "sample-dev-fargate-ecs-task-sg"
    from_port        = 3306
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = [aws_security_group.fargate_ecs_task.id]
    self             = false
    to_port          = 3306
  }]
  name = "sample-dev-rds-sg"
  tags = {
    Name = "sample-dev-rds-sg"
  }
  vpc_id = aws_vpc.this.id
}