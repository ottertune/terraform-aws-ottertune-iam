terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.72.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

resource "aws_iam_role" "ottertune_role" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = "arn:aws:iam::${var.ottertune_account_id}:root"
        }
        Condition = {
          StringEquals = var.external_id
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "ottertune_db_policy" {
  statement {
    actions = [
      "aws-portal:ViewBilling",
      "budgets:Describe*",
      "ce:Describe*",
      "ce:Get*",
      "ce:List*",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "iam:SimulatePrincipalPolicy",
      "pi:DescribeDimensionKeys",
      "pi:GetResourceMetrics",
      "pricing:Describe*",
      "pricing:Get*",
      "rds:Describe*",
      "rds:List*",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ottertune_connect_policy" {
  statement {
    actions = ["rds-db:connect"]
    resources = ["arn:aws:rds-db:*:*:dbuser:*/ottertune*"]
  }
}


data "aws_iam_policy_document" "ottertune_tuning_policy" {
  statement {
    actions = ["rds:ModifyDBParameterGroup"]
    resources = var.tunable_parameter_group_arns
  }
}

data "aws_iam_policy_document" "ottertune_cluster_tuning_policy" {
  statement {
    actions = ["rds:ModifyDBParameterGroup"]
    resources = var.tunable_aurora_cluster_parameter_group_arns
  }
}