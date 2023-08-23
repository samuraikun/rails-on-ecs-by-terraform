terraform {
  required_version = ">= 1.5"
  backend "s3" {
    bucket = "rails-on-ecs-by-terraform-tfstates"
    key    = "production.tfstate"
    region = "ap-northeast-1"
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.region.name
}

module "network" {
  source = "../../modules/network"

  terraform_environment = "production"
  vpc                   = var.vpc
}

module "storage" {
  source = "../../modules/storage"
}

module "app" {
  source = "../../modules/app"

  environment         = "production"
  region              = var.region
  vpc                 = module.network
  s3                  = module.storage
  ecs                 = { web = var.ecs_web }
  server_envs         = { RAILS_ENV = "production" }
  server_secrets      = var.server_secrets
}

module "db" {
  source = "../../modules/db"

  environment = "production"
  vpc         = module.network
  database    = var.database
}
