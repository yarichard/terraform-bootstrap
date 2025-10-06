output "tf_state_bucket_region" {
  description = "Region of the tf_state S3 bucket."
  value       = aws_s3_bucket.tf_state.region
}

output "terraform_state_policy_arn" {
  description = "ARN of the Terraform state access policy."
  value       = aws_iam_policy.terraform_state.arn
}