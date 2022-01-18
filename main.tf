

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

data "aws_iam_policy_document" "code_pipeline_full_access" {
  statement {
    actions = [
      "codepipeline:*",
      "cloudformation:DescribeStacks",
      "cloudformation:ListChangeSets",
      "cloudtrail:CreateTrail",
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetEventSelectors",
      "cloudtrail:PutEventSelectors",
      "cloudtrail:StartLogging",
      "codebuild:BatchGetProjects",
      "codebuild:CreateProject",
      "codebuild:ListCuratedEnvironmentImages",
      "codebuild:ListProjects",
      "codecommit:GetBranch",
      "codecommit:GetRepositoryTriggers",
      "codecommit:ListBranches",
      "codecommit:ListRepositories",
      "codecommit:PutRepositoryTriggers",
      "codecommit:GetReferences",
      "codedeploy:GetApplication",
      "codedeploy:BatchGetApplications",
      "codedeploy:GetDeploymentGroup",
      "codedeploy:BatchGetDeploymentGroups",
      "codedeploy:ListApplications",
      "codedeploy:ListDeploymentGroups",
      "devicefarm:GetDevicePool",
      "devicefarm:GetProject",
      "devicefarm:ListDevicePools",
      "devicefarm:ListProjects",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecs:ListClusters",
      "ecs:ListServices",
      "elasticbeanstalk:DescribeApplications",
      "elasticbeanstalk:DescribeEnvironments",
      "iam:ListRoles",
      "iam:GetRole",
      "lambda:GetFunctionConfiguration",
      "lambda:ListFunctions",
      "events:ListRules",
      "events:ListTargetsByRule",
      "events:DescribeRule",
      "opsworks:DescribeApps",
      "opsworks:DescribeLayers",
      "opsworks:DescribeStacks",
      "s3:GetBucketPolicy",
      "s3:GetBucketVersioning",
      "s3:GetObjectVersion",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "sns:ListTopics",
      "codestar-notifications:ListNotificationRules",
      "codestar-notifications:ListTargets",
      "codestar-notifications:ListTagsforResource",
      "codestar-notifications:ListEventTypes",
      "states:ListStateMachines"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:CreateBucket",
      "s3:PutBucketPolicy"
    ]
    resources = ["arn:aws:s3::*:codepipeline-*"]
  }
  statement {
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::*:role/service-role/cwe-role-*"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["events.amazonaws.com"]
    }
  }
  statement {
    actions   = ["iam:PassRole"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["codepipeline.amazonaws.com"]
    }
  }
  statement {
    actions = [
      "events:PutRule",
      "events:PutTargets",
      "events:DeleteRule",
      "events:DisableRule",
      "events:RemoveTargets"
    ]
    resources = ["arn:aws:events:*:*:rule/codepipeline-*"]
  }
  statement {
    actions = [
      "codestar-notifications:CreateNotificationRule",
      "codestar-notifications:DescribeNotificationRule",
      "codestar-notifications:UpdateNotificationRule",
      "codestar-notifications:DeleteNotificationRule",
      "codestar-notifications:Subscribe",
      "codestar-notifications:Unsubscribe"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "codestar-notifications:NotificationsForResource"
      values   = ["arn:aws:codepipeline:*"]
    }
  }
  statement {
    sid = "CodeStarNotificationsSnsTopicCreateAccess"
    actions = [
      "sns:CreateTopic",
      "sns:SetTopicAttributes"
    ]
    resources = ["arn:aws:sns:*:*:codestar-notifications*"]
  }
  statement {
    sid = "CodeStarNotificationsChatbotAccess"
    actions = [
      "chatbot:DescribeSlackChannelConfigurations"
    ]
    resources = ["*"]
  }
}

module "aggregated_managed_policy" {
  source  = "cloudposse/iam-policy-document-aggregator/aws"
  version = "0.8.0"

  source_documents = [
    data.aws_iam_policy_document.code_pipeline_approver_access.json,
    data.aws_iam_policy_document.s3_full_access.json,
    data.aws_iam_policy_document.code_build_developers_access.json,
    data.aws_iam_policy_document.elasti_cache_read_only_access.json,
    data.aws_iam_policy_document.cloud_watch_logs_read_only_access.json,
    data.aws_iam_policy_document.rds_read_only_access.json,
    data.aws_iam_policy_document.code_pipeline_full_access.json,
  ]
}

data "aws_iam_policy_document" "parameter_store" {
  statement {
    actions = ["ssm:GetParameter"]
    resources = [
      "*"
    ]
    effect = "Allow"
  }
}
