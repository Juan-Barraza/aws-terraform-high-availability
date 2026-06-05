variable "vpc_id" {
  type = string
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

variable "public_subnets_ids" {
  type = list(string)
}

variable "private_subnets_ids" {
  type = list(string)
}

variable "ec2_spects" {
  type = map(string)
}


variable "key_pairs_name" {
  type = string
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

variable "efs_id" {
  type = string
}
