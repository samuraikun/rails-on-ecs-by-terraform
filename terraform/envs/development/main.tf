terraform {
  required_version = ">= 0.14"
  backend "s3" {
    bucket = "rails-on-ecs-by-terraform-tfstates"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = var.region.name
}

module "network" {
  source = "../../modules/network"

  terraform_environment = "development"
  vpc                   = var.vpc
}

module "app" {
  source = "../../modules/app"

  environment         = "staging"
  region              = var.region
  vpc                 = module.network
  ecs                 = { web = var.ecs_web }
  server_envs         = { RAILS_ENV = "staging" }
  server_secrets      = var.server_secrets
}

module "db" {
  source = "../../modules/db"

  environment = "staging"
  vpc         = module.network
  database    = var.database
}
