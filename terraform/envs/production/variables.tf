variable "region" {
  type = map
  default = {
    name = "ap-northeast-1"
  }
}

variable "vpc" {
  type = object({
    vpc = string
    public_subnets = list(object({
      cidr_block              = string
      availability_zone       = string
      map_public_ip_on_launch = bool
      name                    = string
    }))
    private_subnets = list(object({
      cidr_block              = string
      availability_zone       = string
      name                    = string
      pair_public_index       = number
    }))
    aws_security_groups = object({
      web = object({
        name        = string
        description = string
      })
      elb = object({
        name        = string
        description = string
      })
      rds = object({
        name        = string
        description = string
      })
    })
  })

  default = {
    vpc     = "172.16.0.0/16"
    public_subnets = [
      { cidr_block = "172.16.0.0/24", availability_zone = "ap-northeast-1a", map_public_ip_on_launch = true,  name = "app" },
      { cidr_block = "172.16.1.0/24", availability_zone = "ap-northeast-1a", map_public_ip_on_launch = false, name = "app(RDS)" },
      { cidr_block = "172.16.2.0/24", availability_zone = "ap-northeast-1c", map_public_ip_on_launch = true,  name = "app.c" },
      { cidr_block = "172.16.3.0/24", availability_zone = "ap-northeast-1c", map_public_ip_on_launch = false, name = "app(Lambda)" },
      { cidr_block = "172.16.4.0/24", availability_zone = "ap-northeast-1c", map_public_ip_on_launch = false, name = "app(RDS).c" },
    ]
    private_subnets = [
      { cidr_block = "172.16.5.0/24", availability_zone = "ap-northeast-1a", name = "app_private.a", pair_public_index = 0 },
      { cidr_block = "172.16.6.0/24", availability_zone = "ap-northeast-1c", name = "app_private.c", pair_public_index = 2 },
    ]
    aws_security_groups = {
      web = {
        name        = "production.web"
        description = "for production.web"
      }
      elb = {
        name        = "production.elb.load-balancer"
        description = "productions.elb.load-balancer"
      }
      rds = {
        name        = "production.rds"
        description = "production.rds"
      }
    }
  }
}

variable "ecs_web" {
  type = map
  default = {
    log_retention_in_days              = 7
    ecr_image                          = "464352955943.dkr.ecr.ap-northeast-1.amazonaws.com/rails-api:latest"
    cpu                                = 256
    memory                             = 512
    host_port                          = 80
    container_port                     = 80
    desired_count                      = 1
    deployment_minimum_healthy_percent = 100
    deployment_maximum_percent         = 200
    health_check_path                  = "/health_check"
    scale_out_by_cpu                   = 80
    scale_in_by_cpu                    = 30
    scale_out_by_memory                = 80
    scale_in_by_memory                 = 30
    max_capacity                       = 2
    min_capacity                       = 1
    certificate_arn                    = ""
    deregistration_delay               = 0
  }
}

variable "server_secrets" {
  type = list
  default = [
    "RAILS_LOG_TO_STDOUT",
    "RAILS_MAX_THREADS"
    # "AWS_DEFAULT_REGION",
    # "AWS_SECRET_ACCESS_KEY",
    # "SSM_AGENT_CODE",
    # "SSM_AGENT_ID"
  ]
}

variable "database" {
  type = map
  default = {
    instance_class = "db.t2.small"
  }
}
