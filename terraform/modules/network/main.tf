variable "vpc" {}
variable "terraform_environment" {}

resource "aws_vpc" "app_network" {
  cidr_block           = var.vpc.vpc
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name    = "${var.terraform_environment}-network"
  }
}

resource "aws_network_acl" "app_acl" {
  vpc_id     = aws_vpc.app_network.id
  subnet_ids = concat(aws_subnet.app_public[*].id, aws_subnet.app_private[*].id)

  ingress {
    from_port  = 0
    to_port    = 0
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    from_port  = 0
    to_port    = 0
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "${var.terraform_environment}-app-acl"
  }
}