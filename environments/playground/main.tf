terraform {
  backend "s3" {
    bucket  = "creatiwww-eks-terraform-state"
    encrypt = true
    key     = "terraform.tfstate"
    region  = "us-east-1"
    # dynamodb_table = "terraform-state-lock-dynamo" - uncomment this line once the terraform-state-lock-dynamo has been terraformed
  }
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr_block = var.vpc_cidr_block
  subnets_count  = var.subnets_count
}

data "aws_subnet_ids" "subnet" {
  vpc_id = module.vpc.aws_vpc_id
}

module "efs" {
  source             = "../../modules/efs"
  count              = var.subnets_count
  vpc_subnets        = tolist(data.aws_subnet_ids.subnet.ids)[count.index]
  vpc_id             = module.vpc.aws_vpc_id
  vpc_cidr_block     = var.vpc_cidr_block
  subnets_count      = var.subnets_count
}

module "eks_cluster" {
  source             = "../../modules/eks"
  count              = var.subnets_count
  vpc_subnets        = tolist(data.aws_subnet_ids.subnet.ids)[count.index]
  instance_types     = var.instance_types
  nodes_desired_size = var.nodes_desired_size
  nodes_max_size     = var.nodes_max_size
  nodes_min_size     = var.nodes_min_size
}
