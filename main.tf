terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.53.0"
    }
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.ottertune_account_id}:root"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"

      values = [var.external_id]
    }
  }
}

resource "aws_iam_role" "ottertune_role" {
  name               = var.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
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
    actions   = ["rds-db:connect"]
    resources = ["arn:aws:rds-db:*:*:dbuser:*/ottertune*"]
  }
}


data "aws_iam_policy_document" "ottertune_tuning_policy" {
  statement {
    actions   = ["rds:ModifyDBParameterGroup"]
    resources = var.tunable_parameter_group_arns
  }
}

data "aws_iam_policy_document" "ottertune_cluster_tuning_policy" {
  statement {
    actions   = ["rds:ModifyDBParameterGroup"]
    resources = var.tunable_aurora_cluster_parameter_group_arns
  }
}

data "aws_iam_policy_document" "ottertune_policy_document_combined" {
  source_policy_documents = concat([data.aws_iam_policy_document.ottertune_db_policy.json,
    data.aws_iam_policy_document.ottertune_connect_policy.json],
    length(var.tunable_parameter_group_arns) > 0 ? [data.aws_iam_policy_document.ottertune_tuning_policy.json] : [],
  length(var.tunable_aurora_cluster_parameter_group_arns) > 0 ? [data.aws_iam_policy_document.ottertune_cluster_tuning_policy.json] : [])
}

resource "aws_iam_policy" "ottertune_policy" {
  name   = "${var.iam_role_name}_policy"
  policy = data.aws_iam_policy_document.ottertune_policy_document_combined.json
}

resource "aws_iam_role_policy_attachment" "attach_db_policy" {
  role       = aws_iam_role.ottertune_role.name
  policy_arn = aws_iam_policy.ottertune_policy.arn
}