output "tf_state_bucket_region" {
  description = "Region of the tf_state S3 bucket."
  value       = aws_s3_bucket.tf_state.region
}

output "terraform_state_policy_arn" {
  description = "ARN of the Terraform state access policy."
  value       = aws_iam_policy.terraform_state_policy.arn
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_terraform_role_name" {
  description = "GitHub Actions role name for Terraform state access."
  value       = aws_iam_role.github_actions_terraform.name
}

output "ecr_push_pull_policy_arn" {
  description = "ARN of the shared GitHub Actions ECR push/pull policy."
  value       = aws_iam_policy.ecr_push_pull.arn
}