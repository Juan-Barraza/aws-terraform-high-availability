output "app_url" {
  value = module.compute.alb_dns_name
  description = "URL to prove api"
}
output "efs_id" {
  value = module.efs.efs_id
}

output "al2023_ami" {
  value = local.al2023_ami_id
  description = "The latest Amazon Linux 2023 AMI ID"
}