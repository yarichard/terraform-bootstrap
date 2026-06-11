variable "region" {
  description = "Default region for resources."
  type        = string
  default     = "eu-west-3"
}

variable "aws_account_id" {
  description = "AWS Account ID for ECR image URI."
  type        = string
  default     = "704496393752"
}

variable "terraform_bucket" {
  description = "S3 bucket for Terraform state."
  type        = string
  default     = "terraform-state-bucket"
}

variable "github_repositories_allowed_for_terraform" {
  description = "List of GitHub repositories allowed for OIDC. to perform terraform operations"
  type        = list(string)
  default     = ["infra-wam_message", "infra-mountain-race", "infra-famicare"]
}