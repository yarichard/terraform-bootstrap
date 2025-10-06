# Terraform bootstarp project

How to bootstrap from scratch
- comment code block in terraform.tf

~~~
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-yrichard"
    key            = "bootstrap/terraform.tfstate"
    region         = "eu-west-3"
    encrypt        = true
  }
}
~~~~

- run terraform init
- run terraform apply
- uncomment code block
- run terraform init and accept moving tfstate to S3