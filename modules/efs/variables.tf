variable "tags" {
  type = map(string)
}

variable "vpc_id" {
  type = string
}

variable "ingress_efs" {
  type = object({
    port_from = number,
    to_port   = number
  })
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "vpc_cidr" {
  type = string
}
