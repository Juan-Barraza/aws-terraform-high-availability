output "alb_dns_name" {
  value       = aws_lb.alb_instance_bkd.dns_name
  description = "Public direccion to backend access"
}

output "presistence_sg_id" {
  value = aws_security_group.private_instance_persistence_sg.id
  description = "ID security group to EFS"
}