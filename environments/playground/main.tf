terraform {
  backend "s3" {
    bucket  = "creatiwww-eks-terraform-state"
    encrypt = true
    key     = "terraform.tfstate"
    region  = "us-east-1"
    # dynamodb_table = "terraform-state-lock-dynamo" - uncomment this line once the terraform-state-lock-dynamo has been terraformed
  }
}

locals {
  vpc_cidr_block = "10.0.0.0/16"
}

module "vpc" {
  source = "../../modules/vpc"

  cidr_block = local.vpc_cidr_block
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.aws_vpc_id]
  }
}

data "aws_subnet" "subnet" {
  for_each = toset(data.aws_subnets.subnets.ids)
  id       = each.value
}

module "eks_cluster" {
  source = "../../modules/eks"

  vpc_subnets        = data.aws_subnet.subnet
  nodes_desired_size = var.nodes_desired_size
  nodes_max_size     = var.nodes_max_size
  nodes_min_size     = var.nodes_min_size
}
