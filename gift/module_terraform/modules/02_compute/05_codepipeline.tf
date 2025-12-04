# ================================================
# S3 Bucket for CodePipeline
# ================================================
resource "aws_s3_bucket" "codepipeline" {
  bucket = "codepipeline-ap-southeast-2-${data.aws_caller_identity.current.account_id}-mizoka"
}

resource "aws_s3_bucket_versioning" "codepipeline" {
  bucket = aws_s3_bucket.codepipeline.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ================================================
# CodeCommit Repository
# ================================================
resource "aws_codecommit_repository" "this" {
  repository_name = var.codecommit_repository_name
  description     = "Repository for ECS deployment configuration"
}

# ================================================
# CodeDeploy Application
# ================================================
resource "aws_codedeploy_app" "this" {
  compute_platform = "ECS"
  name             = "AppECS-${aws_ecs_cluster.fargate.name}-${aws_ecs_service.fargate.name}"
}

# ================================================
# CodeDeploy DeployGroup
# ================================================
resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "DgpECS-${aws_ecs_cluster.fargate.name}-${aws_ecs_service.fargate.name}"
  service_role_arn       = aws_iam_role.AWSCodeDeployRoleForECS.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 1440
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1440
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.fargate.name
    service_name = aws_ecs_service.fargate.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.alb_listener["alb_80_arn"]]
      }

      target_group {
        name = "${aws_ecs_cluster.fargate.name}-tg01"
      }

      target_group {
        name = "${aws_ecs_cluster.fargate.name}-tg02"
      }

      test_traffic_route {
        listener_arns = [var.alb_listener["alb_8080_arn"]]
      }
    }
  }
}

# ================================================
# IAM Role - CodeDeploy
# ================================================
resource "aws_iam_role" "AWSCodeDeployRoleForECS" {
  name = "sample-AWSCodeDeployRoleForECS"
  path = "/"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codedeploy.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRoleForECS" {
  role       = aws_iam_role.AWSCodeDeployRoleForECS.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

# ================================================
# CodePipeline
# ================================================
resource "aws_codepipeline" "this" {
  name     = "sample-dev-codepipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      category = "Source"
      configuration = {
        BranchName           = "main"
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
        PollForSourceChanges = "false"
        RepositoryName       = var.codecommit_repository_name
      }
      name             = "Source"
      namespace        = "SourceVariables"
      output_artifacts = ["SourceArtifact"]
      owner            = "AWS"
      provider         = "CodeCommit"
      region           = "ap-southeast-2"
      run_order        = 1
      version          = 1
    }
  }

  stage {
    name = "Build"
    action {
      category = "Build"
      configuration = {
        ProjectName = "sample-dev-build-project"
        EnvironmentVariables = jsonencode([
          {
            name  = "API_NAME"
            value = "sample"
            type  = "PLAINTEXT"
          }
        ])
      }
      input_artifacts  = ["SourceArtifact"]
      name             = "Build"
      namespace        = "BuildVariables"
      output_artifacts = ["BuildArtifact"]
      owner            = "AWS"
      provider         = "CodeBuild"
      region           = "ap-southeast-2"
      run_order        = 1
      version          = 1
    }
  }

  stage {
    name = "Approval"
    action {
      category = "Approval"
      configuration = {
        CustomData = "デプロイ承認をお願い致します。"
      }
      name      = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      region    = "ap-southeast-2"
      run_order = 1
      version   = 1
    }
  }

  stage {
    name = "Deploy"
    action {
      category = "Deploy"
      configuration = {
        AppSpecTemplateArtifact        = "BuildArtifact"
        AppSpecTemplatePath            = "appspec.yaml"
        ApplicationName                = aws_codedeploy_app.this.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.this.deployment_group_name
        Image1ArtifactName             = "BuildArtifact"
        Image1ContainerName            = "ImageURI"
        TaskDefinitionTemplateArtifact = "BuildArtifact"
        TaskDefinitionTemplatePath     = "taskdef.json"
      }
      input_artifacts = ["BuildArtifact"]
      name            = "Deploy"
      namespace       = "DeployVariables"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      region          = "ap-southeast-2"
      run_order       = 1
      version         = 1
    }
  }
}

# ================================================
# IAM Roles
# ================================================
resource "aws_iam_role" "codepipeline" {
  name = "sample-dev-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline" {
  name = "sample-dev-codepipeline-policy"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::codepipeline-ap-southeast-2-${data.aws_caller_identity.current.account_id}",
          "arn:aws:s3:::codepipeline-ap-southeast-2-${data.aws_caller_identity.current.account_id}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codecommit:CancelUploadArchive",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:UploadArchive"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "codebuild" {
  name = "sample-dev-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild" {
  name = "sample-dev-codebuild-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

# ================================================
# CodeBuild
# ================================================
resource "aws_codebuild_project" "this" {
  name         = "sample-dev-build-project"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    name = "sample-dev-build-project"
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
    environment_variable {
      name  = "IMAGE_TAG_PREFIX"
      value = "DEV"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/sample-dev-build-project"
      status     = "ENABLED"
    }
  }

  source {
    type = "CODEPIPELINE"
  }
}

resource "aws_cloudwatch_log_group" "cicd" {
  name = "/aws/codebuild/sample-dev-build-project"
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# ================================================
# Outputs
# ================================================
output "codecommit_repository_url" {
  description = "URL of the CodeCommit repository"
  value       = aws_codecommit_repository.this.clone_url_http
}

output "codecommit_repository_ssh_url" {
  description = "SSH URL of the CodeCommit repository"
  value       = aws_codecommit_repository.this.clone_url_ssh
} 