// Allowing Github action Role for Terraform state access for given repos
data "aws_iam_policy_document" "github_actions_terraform_role_document_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    # Must always match
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Allow every branch for all projects
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = flatten([
        for repo in var.github_repositories_allowed_for_terraform : [
          "repo:yarichard/${repo}:ref:refs/heads/*",
          "repo:yarichard/${repo}:ref:refs/tags/*",
          "repo:yarichard/${repo}:pull_request"
        ]
      ])
    }
  }
}

resource "aws_iam_role" "github_actions_terraform" {
  name               = "GitHubActionTerraformRole"
  description        = "Allow Github action to R/W terraform state"
  assume_role_policy = data.aws_iam_policy_document.github_actions_terraform_role_document_policy.json
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

  statement {
    actions = [
      "iam:ListAttachedRolePolicies"
    ]
    resources = [
      aws_iam_role.github_actions_terraform.arn
    ]
  }
}

resource "aws_iam_policy" "terraform_state_policy" {
  name   = "TerraformStatePolicy"
  policy = data.aws_iam_policy_document.terraform_state.json
}

// Attach Policy to the GitHub OIDC Role (reference from bootstrap tfstate)
resource "aws_iam_role_policy_attachment" "terraform_state_attach" {
  role       = aws_iam_role.github_actions_terraform.name
  policy_arn = aws_iam_policy.terraform_state_policy.arn
}
