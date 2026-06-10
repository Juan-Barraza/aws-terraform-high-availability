
variable "notification_email" {
  type = string
  default = ""
}

variable "enable_ses" {
  type = bool
  default = false
}

variable "enable_ses_monitoring" {
  type        = bool
  default     = false
}

variable "use_domain_identity" {
  type    = bool
  default = false  # false = dev, true = prod
}

variable "ses_domain" {
  type    = string
  default = ""
}