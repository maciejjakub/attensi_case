resource "aws_ecr_repository" "ecr" {
  name = "slowcalc"
}

resource "aws_apprunner_service" "slowcalc" {
  service_name                   = "slowcalc_the_second"
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.autoscale_config.arn

  instance_configuration {
    cpu    = 2048
    memory = 4096
  }

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.app_runner_ecr_role.arn
    }
    image_repository {
      image_configuration {
        port = "80"
      }
      image_identifier      = "348943158988.dkr.ecr.eu-west-1.amazonaws.com/slowcalc:latest"
      image_repository_type = "ECR"
    }
    auto_deployments_enabled = false
  }

  tags = {
    Name = "slowcalc"
  }
}

resource "aws_apprunner_auto_scaling_configuration_version" "autoscale_config" {
  auto_scaling_configuration_name = "slowcalc_autoscale_config"

  max_concurrency = 200
  max_size        = 25
  min_size        = 2

  tags = {
    Name = "slowcalc"
  }
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.app_runner_ecr_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "app_runner_ecr_role" {
  name = "app_runner_ecr_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement : [
      {
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}