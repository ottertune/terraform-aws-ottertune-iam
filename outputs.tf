output "ottertune_role_arn" {
  description = "Use this Role ARN to complete setup on https://service.ottertune.com"
  value = aws_iam_role.ottertune_role.arn
}
