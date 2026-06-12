resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.app_name}-dns-updater"
  retention_in_days = var.log_retention_days
  tags              = { Name = "${var.app_name}-dns-updater" }
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${replace(title(replace(var.app_name, "-", " ")), " ", "")}DNSUpdaterRole"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = { Name = "${var.app_name}-dns-updater" }
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid       = "DescribeECSTasks"
    effect    = "Allow"
    actions   = ["ecs:DescribeTasks"]
    resources = ["arn:aws:ecs:${var.region}:${var.aws_account_id}:task/${var.ecs_cluster_name}/*"]
  }

  statement {
    sid       = "DescribeENI"
    effect    = "Allow"
    actions   = ["ec2:DescribeNetworkInterfaces"]
    resources = ["*"]
  }

  statement {
    sid    = "UpdateOriginRecord"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
    resources = ["arn:aws:route53:::hostedzone/${var.hosted_zone_id}"]
  }

  statement {
    sid    = "WriteLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.this.arn}:*"]
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "DNSUpdaterPolicy"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.policy.json
}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/dns_updater"
  output_path = "${path.root}/.terraform/${var.app_name}-dns-updater.zip"
}

resource "aws_lambda_function" "this" {
  function_name    = "${var.app_name}-dns-updater"
  role             = aws_iam_role.this.arn
  runtime          = "python3.12"
  handler          = "handler.handler"
  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256
  timeout          = 30

  environment {
    variables = {
      ECS_CLUSTER     = var.ecs_cluster_name
      HOSTED_ZONE_ID  = var.hosted_zone_id
      ORIGIN_HOSTNAME = var.origin_hostname
    }
  }

  depends_on = [aws_cloudwatch_log_group.this]
  tags       = { Name = "${var.app_name}-dns-updater" }
}

resource "aws_cloudwatch_event_rule" "this" {
  name        = "${var.app_name}-task-running"
  description = "Fires when a ${var.app_name} ECS task reaches RUNNING state"

  event_pattern = jsonencode({
    source        = ["aws.ecs"]
    "detail-type" = ["ECS Task State Change"]
    detail = {
      clusterArn = [var.ecs_cluster_arn]
      lastStatus = ["RUNNING"]
    }
  })

  tags = { Name = "${var.app_name}-dns-updater" }
}

resource "aws_cloudwatch_event_target" "this" {
  rule = aws_cloudwatch_event_rule.this.name
  arn  = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}
