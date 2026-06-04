output "app_url" {
  value = module.compute.alb_dns_name
  description = "URL to prove api"
}