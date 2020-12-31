resource "aws_security_group" "web" {
  name        = var.vpc.aws_security_groups.web.name
  description = var.vpc.aws_security_groups.web.description
  vpc_id      = aws_vpc.app_network.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = [aws_vpc.app_network.cidr_block]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.terraform_environment}-web-sg"
  }
}

resource "aws_security_group" "elb" {
  name        = var.vpc.aws_security_groups.elb.name
  description = var.vpc.aws_security_groups.elb.description
  vpc_id      = aws_vpc.app_network.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elb-sg"
  }
}

resource "aws_security_group" "rds" {
    name        = var.vpc.aws_security_groups.rds.name
    description = var.vpc.aws_security_groups.rds.description
    vpc_id      = aws_vpc.app_network.id

    ingress {
      from_port       = 3306
      to_port         = 3306
      protocol        = "tcp"
      cidr_blocks     = [aws_vpc.app_network.cidr_block]
    }

    egress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
    }

    tags = {
      Name = "rds-sg"
    }
}

resource "aws_security_group" "vpc_endpoint" {
  name   = "vpc_endpoint_sg"
  vpc_id = aws_vpc.app_network.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.app_network.cidr_block]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.app_network.cidr_block]
  }

  tags = {
    Name = "vpc-endpoint"
  }
}
