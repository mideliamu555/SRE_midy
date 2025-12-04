# ================================================
# EFS File System
# ================================================
resource "aws_efs_file_system" "main" {
  creation_token = "sample-dev-efs"
  encrypted      = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "sample-dev-efs"
  }
}

# ================================================
# EFS Mount Targets
# ================================================
resource "aws_efs_mount_target" "main" {
  for_each = {
    "protected_a" = var.subnet.protected_a_id
    "protected_c" = var.subnet.protected_c_id
  }

  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}

# ================================================
# Security Group for EFS
# ================================================
resource "aws_security_group" "efs" {
  name        = "sample-dev-efs-sg"
  description = "Security group for EFS mount targets"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from ECS tasks"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.security_group["fargate_ecs_task_id"]]
  }

  tags = {
    Name = "sample-dev-efs-sg"
  }
}

# ================================================
# IAM Policy for EFS Access
# ================================================
resource "aws_iam_policy" "EFSAccess" {
  name = "sample-AmazonEFSAccessPolicy"
  path = "/"
  policy = jsonencode({
    Statement = [{
      Action = [
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:ClientRootAccess"
      ]
      Effect   = "Allow"
      Resource = aws_efs_file_system.main.arn
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "EFSAccess_fargate_ecs" {
  role       = aws_iam_role.fargate_ecs_task.name
  policy_arn = aws_iam_policy.EFSAccess.arn
} 