# ================================================
# CodePipeline
# ================================================
resource "aws_codepipeline" "this" {
  name     = "sample-dev-ecs-pipeline"
  role_arn = aws_iam_role.codepipeline_service.arn

  artifact_store {
    location = aws_s3_bucket.artifact.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = var.codecommit_repository_name
        BranchName     = "main"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.this.name
        DeploymentGroupName = aws_codedeploy_deployment_group.this.deployment_group_name
      }
    }
  }
}

# ================================================
# S3 Bucket for Artifacts
# ================================================
resource "aws_s3_bucket" "artifact" {
  bucket = "sample-dev-artifact-bucket-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "sample-dev-artifact-bucket"
  }
}

resource "aws_s3_bucket_versioning" "artifact" {
  bucket = aws_s3_bucket.artifact.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# ================================================
# IAM Role for CodePipeline
# ================================================
resource "aws_iam_role" "codepipeline_service" {
  name = "sample-dev-codepipeline-service-role"

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

resource "aws_iam_role_policy" "codepipeline_service" {
  name = "sample-dev-codepipeline-service-policy"
  role = aws_iam_role.codepipeline_service.id

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
          aws_s3_bucket.artifact.arn,
          "${aws_s3_bucket.artifact.arn}/*"
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