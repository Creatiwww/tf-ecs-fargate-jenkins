resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  # enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  # Enabling automatic public IP assignment on instance launch!
  # map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = "default-subnet"
  }

  depends_on = [
    aws_vpc.main,
  ]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-vpc-ig"
  }

  depends_on = [
    aws_vpc.main,
  ]
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

data "aws_subnets" "vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.main.id]
  }
}

data "aws_subnet" "vpc_subnets" {
  for_each = toset(data.aws_subnets.vpc_subnets.ids)
  id       = each.value
}
