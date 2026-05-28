locals {
  name_prefix = join("", [for part in split("-", var.app_name) : title(part)])
}

resource "aws_iam_role" "apprunner_ecr" {
  name = "${local.name_prefix}AppRunnerECRRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "build.apprunner.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_ecr_readonly" {
  role       = aws_iam_role.apprunner_ecr.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy_document" "github_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.github_oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = flatten([for repo in var.github_repositories : [
        "repo:yarichard/${repo}:ref:refs/heads/*",
        "repo:yarichard/${repo}:ref:refs/tags/*",
        "repo:yarichard/${repo}:pull_request"
      ]])
    }
  }
}

resource "aws_iam_role" "github_ecr_push" {
  name               = "GitHubActionECRPushRoleFor${local.name_prefix}"
  assume_role_policy = data.aws_iam_policy_document.github_assume.json
}

resource "aws_iam_role_policy_attachment" "github_ecr_push" {
  role       = aws_iam_role.github_ecr_push.name
  policy_arn = var.ecr_push_pull_policy_arn
}
