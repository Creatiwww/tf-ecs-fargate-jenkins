# terraform {
#   backend "s3" {
#     bucket  = "terraform-backend-store"
#     encrypt = true
#     key     = "terraform.tfstate"
#     region  = "eu-central-1"
#     # dynamodb_table = "terraform-state-lock-dynamo" - uncomment this line once the terraform-state-lock-dynamo has been terraformed
#   }
# }

locals {
  vpc_cidr_block = "10.0.0.0/16"
}

module "vpc" {
  source = "../../modules/vpc"

  cidr_block = local.vpc_cidr_block
}

module "eks_cluster" {
  source = "../../modules/eks"

  vpc_subnets        = module.vpc.vpc_subnet_ids
  nodes_desired_size = var.nodes_desired_size
  nodes_max_size     = var.nodes_max_size
  nodes_min_size     = var.nodes_min_size
}
