resource "aws_subnet" "app_private" {
  count             = length(var.vpc.private_subnets)
  vpc_id            = aws_vpc.app_network.id
  cidr_block        = var.vpc.private_subnets[count.index].cidr_block
  availability_zone = var.vpc.private_subnets[count.index].availability_zone

  tags = {
    Name = "${var.terraform_environment}_private_${var.vpc.private_subnets[count.index].name}"
  }
}

resource "aws_route_table" "app_private" {
  count  = length(aws_subnet.app_private)
  vpc_id = aws_vpc.app_network.id

  route {
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "${var.terraform_environment}_private_${var.vpc.private_subnets[count.index].availability_zone}"
  }
}

resource "aws_route_table_association" "app_private" {
  count          = length(aws_subnet.app_private)
  subnet_id      = aws_subnet.app_private[count.index].id
  route_table_id = aws_route_table.app_private[count.index].id
}