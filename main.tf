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
    actions = flatten([
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
      "rds:Describe*",
      "rds:List*",
      var.permissions_level == "write_limited" ? [
      "rds:ModifyDBInstance",
      "rds:ModifyDBCluster",
      ] : []
    ])
    resources = ["*"]
  }
}


data "aws_iam_policy_document" "ottertune_copy_pg_policy" {
  statement {
    actions   = [
      "rds:CopyDBParameterGroup",
      "rds:CopyDBClusterParameterGroup",
    ]
    resources = [
      "arn:aws:rds:*:*:pg:*",
      "arn:aws:rds:*:*:cluster-pg:*"
    ]
  }
}


data "aws_iam_policy_document" "ottertune_pg_policy" {
  statement {
    actions   = [
      "rds:CreateDBParameterGroup",
      "rds:ModifyDBParameterGroup",
    ]
    resources = ["arn:aws:rds:*:*:pg:ottertune*"]
  }
}


data "aws_iam_policy_document" "ottertune_cluster_pg_policy" {
  statement {
    actions   = [
      "rds:CreateDBClusterParameterGroup",
      "rds:ModifyDBClusterParameterGroup",
    ]
    resources = ["arn:aws:rds:*:*:cluster-pg:ottertune*"]
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
    actions   = ["rds:ModifyDBClusterParameterGroup"]
    resources = var.tunable_aurora_cluster_parameter_group_arns
  }
}

data "aws_iam_policy_document" "ottertune_policy_document_combined" {
  source_policy_documents = concat([data.aws_iam_policy_document.ottertune_db_policy.json],
    var.permissions_level == "write_limited" ? [data.aws_iam_policy_document.ottertune_copy_pg_policy.json, data.aws_iam_policy_document.ottertune_pg_policy.json, data.aws_iam_policy_document.ottertune_cluster_pg_policy.json] :  [],
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