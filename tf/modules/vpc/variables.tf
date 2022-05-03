variable "vpc_cidr_block" {
  description = "cidr blocks for VPC"
  type        = string
}

variable "subnets_count" {
  description = "amount of subnets to be created"
  type        = number
}
