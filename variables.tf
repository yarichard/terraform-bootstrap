
variable "terraform_bucket" {
  description = "S3 bucket for Terraform state."
  type        = string
  default     = "terraform-state-bucket"
}