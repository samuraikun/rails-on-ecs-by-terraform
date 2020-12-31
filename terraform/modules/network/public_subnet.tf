resource "aws_subnet" "app_public" {
  count                   = length(var.vpc.public_subnets)
  vpc_id                  = aws_vpc.app_network.id
  cidr_block              = var.vpc.public_subnets[count.index].cidr_block
  availability_zone       = var.vpc.public_subnets[count.index].availability_zone
  map_public_ip_on_launch = var.vpc.public_subnets[count.index].map_public_ip_on_launch

  tags = {
    Name = "${var.terraform_environment}_public_${var.vpc.public_subnets[count.index].name}"
  }
}

resource "aws_internet_gateway" "app_public" {
  vpc_id = aws_vpc.app_network.id
}

resource "aws_route_table" "app_public" {
  count  = length(aws_subnet.app_public)
  vpc_id = aws_vpc.app_network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_public.id
  }

  tags = {
    Name = "${var.terraform_environment}_public_${var.vpc.public_subnets[count.index].availability_zone}"
  }
}

resource "aws_route_table_association" "app_public" {
  count          = length(aws_subnet.app_public)
  subnet_id      = aws_subnet.app_public[count.index].id
  route_table_id = aws_route_table.app_public[count.index].id
}
