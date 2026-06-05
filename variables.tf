variable "region_provider" {
  type = string
}
variable "virginia_vpc" {
  type = object({
    name  = string,
    env   = string,
    owner = string,
    cidr  = string,
  })
}

variable "public_subnets" {
  description = "List public subnets "
  type        = list(string)
}

variable "private_subnets" {
  description = "List private subnets "
  type        = list(string)
}



variable "route_table_cidr" {
  type = string
}

variable "zone" {
  type = list(string)
}

variable "ingress_port_lis_bkd" {
  type = list(number)
}

variable "ingress_port_lis_persistence" {
  type = list(number)
}

variable "ingress_lb" {
  type = list(number)
}


variable "ec2_spects" {
  type = map(string)
}

variable "tags" {
  type = map(string)
}

variable "target_lb" {
  type = object({
    port     = number,
    protocol = string,
    health_check = object({
      path                = string,
      protocol            = string,
      matcher             = string,
      interval            = number,
      timeout             = number,
      healthy_threshold   = number,
      unhealthy_threshold = number
    }),
  })
}

variable "certificate_arn" {
  type        = string
  default     = null
  description = "ARN of SSL certification (is required in production)"
}

variable "ingress_efs" {
  type = object({
    port_from          = number,
    to_port            = number
  })
}