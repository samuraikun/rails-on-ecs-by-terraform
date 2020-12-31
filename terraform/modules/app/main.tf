variable "environment" {}
variable "region" {}
variable "vpc" {}
variable "ecs" {}
variable "server_envs" {}
variable "server_secrets" {}

data "aws_caller_identity" "self" { }
