# ================================================
# ECS Cluster - fargate
# ================================================
resource "aws_ecs_cluster" "fargate" {
  name = "sample-dev-fargate-ecs-cluster"
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

# ================================================
# ECS Service - fargate
# ================================================
locals {
  subnets = var.create_nat_gateway ? [var.subnet["protected_a_id"], var.subnet["protected_c_id"]] : [var.subnet["public_a_id"], var.subnet["public_c_id"]]
}

resource "aws_ecs_service" "fargate" {
  cluster                = aws_ecs_cluster.fargate.arn
  desired_count          = 1
  enable_execute_command = true
  launch_type            = "FARGATE"
  platform_version       = "LATEST"
  name                   = "sample-dev-fargate-ecs-service"
  task_definition        = aws_ecs_task_definition.fargate.arn
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  load_balancer {
    container_name   = "sample-container"
    container_port   = 80
    target_group_arn = var.target_group["fargate01_arn"]
  }
  network_configuration {
    assign_public_ip = !var.create_nat_gateway
    security_groups  = [var.security_group["fargate_ecs_task_id"]]
    subnets          = local.subnets
  }
  lifecycle {
    ignore_changes = [
      load_balancer,
      task_definition,
      desired_count,
      platform_version
    ]
  }
  depends_on = [aws_ecs_cluster.fargate, aws_ecs_task_definition.fargate]
}


# ================================================
# Task Definition - fargate
# ================================================
resource "aws_ecs_task_definition" "fargate" {
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ECSTaskExecution.arn
  family                   = "sample-dev-fargate-ecs-task"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.fargate_ecs_task.arn

  volume {
    name = "efs-volume"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.main.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      authorization_config {
        iam = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode([{
    name      = "sample-container"
    image     = "nginx:latest"
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
      }
    ]
    mountPoints = [
      {
        sourceVolume  = "efs-volume"
        containerPath = "/mnt/efs"
        readOnly      = false
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/sample-dev-fargate-ecs-task"
        awslogs-region        = "ap-southeast-2"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
  depends_on = [aws_cloudwatch_log_group.fargate_ecs_task, aws_iam_role.ECSTaskExecution, aws_iam_role.fargate_ecs_task, aws_efs_file_system.main]
}


# ================================================
# CloudWatch Log Group
# ================================================
resource "aws_cloudwatch_log_group" "fargate_ecs_task" {
  name              = "/ecs/sample-dev-fargate-ecs-task"
  retention_in_days = 30
}

# ================================================
# IAM Role - ECSTaskExecution
# ================================================
resource "aws_iam_role" "ECSTaskExecution" {
  name = "sample-AmazonECSTaskExecutionRole"
  path = "/"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

locals {
  ecs_task_execution_policies = {
    AmazonECSTaskExecutionRolePolicy = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    SSMGetParameters                 = aws_iam_policy.SSMGetParameters.arn
    GetSecretValue                   = aws_iam_policy.GetSecretValue.arn
  }
}

resource "aws_iam_role_policy_attachment" "ECSTaskExecutionPolicies" {
  for_each   = local.ecs_task_execution_policies
  role       = aws_iam_role.ECSTaskExecution.name
  policy_arn = each.value
}


# ================================================
# IAM Role - fargate_ecs
# ================================================
resource "aws_iam_role" "fargate_ecs_task" {
  name = "sample-dev-fargate-ecs-task-role"
  path = "/"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "ECSExecuteCommand_fargate_ecs" {
  role       = aws_iam_role.fargate_ecs_task.name
  policy_arn = aws_iam_policy.ECSExecuteCommand.arn
}

# ================================================
# IAM Policy
# ================================================
resource "aws_iam_policy" "SSMGetParameters" {
  name = "sample-AmazonSSMGetParametersPolicy"
  path = "/"
  policy = jsonencode({
    Statement = [{
      Action   = ["ssm:GetParameter", "ssm:GetParameters"]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "GetSecretValue" {
  name = "sample-SecretsManagerGetSecretValuePolicy"
  path = "/"
  policy = jsonencode({
    Statement = [{
      Action   = "secretsmanager:GetSecretValue"
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "ECSExecuteCommand" {
  name = "sample-AmazonECSExecuteCommandPolicy"
  path = "/"
  policy = jsonencode({
    Statement = [{
      Action   = ["ssmmessages:CreateControlChannel", "ssmmessages:CreateDataChannel", "ssmmessages:OpenControlChannel", "ssmmessages:OpenDataChannel"]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

# ================================================
# Security Group Rule
# ================================================
resource "aws_security_group_rule" "ecs_to_efs" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.efs.id
  security_group_id        = var.security_group["fargate_ecs_task_id"]
}

# ================================================
# IAM Role Policy - ecs_task_efs
# ================================================
resource "aws_iam_role_policy" "ecs_task_efs" {
  name = "ecs-task-efs-policy"
  role = aws_iam_role.fargate_ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]
        Resource = aws_efs_file_system.main.arn
      }
    ]
  })
}

# ================================================
# EFS Mount Target
# ================================================
resource "aws_efs_mount_target" "this" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.subnet["protected_a_id"]
  security_groups = [aws_security_group.efs.id]
}

# ================================================
# EFS用のVPCエンドポイントが設定されているか確認
# ================================================
resource "aws_vpc_endpoint" "efs" {
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.ap-southeast-2.elasticfilesystem"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [var.subnet["protected_a_id"], var.subnet["protected_c_id"]]
  security_group_ids = [aws_security_group.efs.id]
}