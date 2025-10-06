provider "aws" {
  region = "eu-west-3"
}

// S3 bucket for storing tfstate
// --------------------------------
resource "aws_s3_bucket" "tf_state" {
  force_destroy = true
  bucket        = "terraform-state-bucket-yrichard"

  tags = {
    Name = "terraform"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_sse" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

// IAM Policy for Terraform State Access
data "aws_iam_policy_document" "terraform_state" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.tf_state.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.tf_state.bucket}/*"
    ]
  }
}

resource "aws_iam_policy" "terraform_state" {
  name   = "TerraformStatePolicy"
  policy = data.aws_iam_policy_document.terraform_state.json
}