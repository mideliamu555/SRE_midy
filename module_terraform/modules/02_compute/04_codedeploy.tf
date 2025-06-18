# ================================================
# CodeDeploy Application
# ================================================
resource "aws_codedeploy_app" "this" {
  compute_platform = "ECS"
  name             = "AppECS-sample-dev-fargate-ecs-cluster-sample-dev-fargate-ecs-service"
}

# ================================================
# CodeDeploy DeployGroup
# ================================================
resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "DgpECS-sample-dev-fargate-ecs-cluster-sample-dev-fargate-ecs-service"
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
        name = var.target_group["fargate01_name"]
      }

      target_group {
        name = var.target_group["fargate02_name"]
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