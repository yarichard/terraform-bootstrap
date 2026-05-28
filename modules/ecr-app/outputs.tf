output "apprunner_ecr_role_name" {
  value = aws_iam_role.apprunner_ecr.name
}

output "apprunner_ecr_role_arn" {
  value = aws_iam_role.apprunner_ecr.arn
}

output "github_ecr_push_role_arn" {
  value = aws_iam_role.github_ecr_push.arn
}
