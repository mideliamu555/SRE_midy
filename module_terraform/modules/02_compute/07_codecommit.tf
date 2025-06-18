# ================================================
# CodeCommit Repository
# ================================================
resource "aws_codecommit_repository" "this" {
  repository_name = var.codecommit_repository_name
  description     = "Repository for ECS deployment configuration"
}

# ================================================
# Initial appspec.yaml
# ================================================
resource "local_file" "appspec" {
  filename = "appspec.yaml"
  content  = <<-EOT
version: 0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: <TASK_DEFINITION_ARN>
        LoadBalancerInfo:
          ContainerName: "sample-container"
          ContainerPort: 80
        NetworkConfiguration:
          AwsvpcConfiguration:
            Subnets:
              - ${var.subnet.public_a_id}
              # - ${var.subnet.public_c_id}  # 必要に応じて有効化
EOT
}

# ================================================
# IAM Role for CodeCommit Access
# ================================================
resource "aws_iam_role" "codecommit_access" {
  name = "sample-dev-codecommit-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codecommit.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codecommit_access" {
  name = "sample-dev-codecommit-access-policy"
  role = aws_iam_role.codecommit_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codecommit:GitPull",
          "codecommit:GitPush"
        ]
        Resource = aws_codecommit_repository.this.arn
      }
    ]
  })
} 