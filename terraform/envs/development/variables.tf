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
    vpc     = "192.168.0.0/16"
    public_subnets = [
      { cidr_block = "192.168.0.0/24", availability_zone = "ap-northeast-1a", map_public_ip_on_launch = true,  name = "app" },
      { cidr_block = "192.168.1.0/24", availability_zone = "ap-northeast-1a", map_public_ip_on_launch = false, name = "app(RDS)" },
      { cidr_block = "192.168.2.0/24", availability_zone = "ap-northeast-1c", map_public_ip_on_launch = true,  name = "app.c" },
      { cidr_block = "192.168.3.0/24", availability_zone = "ap-northeast-1c", map_public_ip_on_launch = false, name = "app(Lambda)" },
      { cidr_block = "192.168.4.0/24", availability_zone = "ap-northeast-1c", map_public_ip_on_launch = false, name = "app(RDS).c" },
    ]
    private_subnets = [
      { cidr_block = "192.168.5.0/24", availability_zone = "ap-northeast-1a", name = "app_private.a", pair_public_index = 0 },
      { cidr_block = "192.168.6.0/24", availability_zone = "ap-northeast-1c", name = "app_private.c", pair_public_index = 2 },
    ]
    aws_security_groups = {
      web = {
        name        = "development.web"
        description = "for development.web"
      }
      elb = {
        name        = "development.elb.load-balancer"
        description = "development.elb.load-balancer"
      }
      rds = {
        name        = "development.rds"
        description = "development.rds"
      }
    }
  }
}