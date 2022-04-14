output "aws_vpc_id" {
  value = aws_vpc.main.id
}

output "aws_route_table_id" {
  value = aws_route_table.public-subnet-rt.id
}

output "aws_internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "vpc_subnet_ids" {
  value = [data.aws_subnet.vpc_subnets.*.id]
}
