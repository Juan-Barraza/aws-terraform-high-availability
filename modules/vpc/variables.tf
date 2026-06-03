variable "virginia_vpc" {
  type = object({
    name  = string,
    env   = string,
    owner = string,
    cidr  = string,
  })
}

variable "public_subnets" {
  description = "List subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List private subnets "
  type        = list(string)
}


variable "zone" {
  type = list(string)
}

variable "route_table_cidr" {
  type = string
}
