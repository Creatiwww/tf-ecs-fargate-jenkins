variable "nodes_desired_size" {
  description = "Amount of K8s nodes in EKS cluster"
  type        = number
}

variable "nodes_max_size" {
  description = "Max amount of K8s nodes in EKS cluster"
  type        = number
}

variable "nodes_min_size" {
  description = "Min amount of K8s nodes in EKS cluster"
  type        = number
}

variable "instance_types" {
  description = "EKS node instance type"
  type        = list(string)
}

variable "vpc_cidr_block" {
  description = "cidr blocks for VPC"
  type        = string
}

variable "subnets_count" {
  description = "amount of subnets to be created"
  type        = number
}
