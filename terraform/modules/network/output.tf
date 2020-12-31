output "vpc" {
  value = aws_vpc.app_network
}

output "subnet_public" {
  value = aws_subnet.app_public
}

output "subnet_private" {
  value = aws_subnet.app_private
}

output "security_group_web" {
  value = aws_security_group.web
}

output "security_group_elb" {
  value = aws_security_group.elb
}

output "security_group_rds" {
  value = aws_security_group.rds
}
