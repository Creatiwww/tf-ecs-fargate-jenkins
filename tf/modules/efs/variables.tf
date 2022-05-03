variable "vpc_id" {
  description = "Id of VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "cidr blocks for VPC"
  type        = string
}

variable "vpc_subnets" {
  description = "List of subnets defined in VPC"
  type        = list (any)
}

variable "subnets_count" {
  description = "amount of subnets to be created"
  type        = number
}
