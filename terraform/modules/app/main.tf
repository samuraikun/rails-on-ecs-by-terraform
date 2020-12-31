variable "environment" {}
variable "region" {}
variable "vpc" {}

data "aws_caller_identity" "self" { }