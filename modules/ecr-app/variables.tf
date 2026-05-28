variable "app_name" {
  type        = string
  description = "App name used as IAM name prefix, e.g. 'mountain-race'."
}

variable "github_repositories" {
  type        = list(string)
  description = "GitHub repo names allowed to assume the ECR push role."
}

variable "github_oidc_provider_arn" {
  type        = string
  description = "ARN of the GitHub OIDC provider (from bootstrap)."
}

variable "ecr_push_pull_policy_arn" {
  type        = string
  description = "ARN of the shared ECR push/pull policy (from bootstrap)."
}
