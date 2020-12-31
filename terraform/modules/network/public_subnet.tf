resource "aws_subnet" "app_public" {
  count                   = length(var.vpc.public_subnets)
  vpc_id                  = aws_vpc.app_network.id
  cidr_block              = var.vpc.public_subnets[count.index].cidr_block
  availability_zone       = var.vpc.public_subnets[count.index].availability_zone
  map_public_ip_on_launch = var.vpc.public_subnets[count.index].map_public_ip_on_launch

  tags = {
      Name    = "${var.terraform_environment}_public_${var.vpc.public_subnets[count.index].name}"
  }
}