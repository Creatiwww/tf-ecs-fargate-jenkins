resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "main" {
  count                   = var.subnets_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-vpc-ig"
  }

  # depends_on = [
  #   aws_vpc.main,
  # ]
}

resource "aws_route_table" "public-subnet-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rt-for-ig"
  }

  depends_on = [
    aws_vpc.main,
    aws_internet_gateway.igw,
  ]
}



# data "aws_subnets" "example" {
#   filter {
#     name   = "vpc-id"
#     values = [aws_vpc.main.id]
#   }
# }
#
# data "aws_subnet" "example" {
#   count              = var.subnets_count
#   vpc_subnets        = var.vpc_subnets[count.index]
# }
#
# output "subnet_id" {
#   # value = [for s in data.aws_subnet.example : s.id]

# }
