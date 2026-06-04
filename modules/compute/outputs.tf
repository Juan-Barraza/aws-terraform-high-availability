output "alb_dns_name" {
  value       = aws_lb.alb_instance_bkd.dns_name
  description = "Public direccion to backend access"
}