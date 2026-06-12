variable "app_name" {
  type        = string
  description = "App name, e.g. 'famicare'. Used to name all resources."
}

variable "region" {
  type        = string
  description = "AWS region where the ECS cluster runs."
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID, used to scope IAM resource ARNs."
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ARN of the ECS cluster to watch for task state changes."
}

variable "ecs_cluster_name" {
  type        = string
  description = "Name of the ECS cluster, used to scope ecs:DescribeTasks."
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID where the origin A record lives."
}

variable "origin_hostname" {
  type        = string
  description = "FQDN of the origin A record to update (must end with a dot), e.g. 'origin.famicare.eravest.fr.'."
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention in days."
  default     = 7
}
