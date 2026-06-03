output "vpc_id" {
  value = aws_vpc.vpc_virginia.id
}

output "public_subnet_ids" {
  value       = aws_subnet.public_subnet[*].id
  description = "return list with all public subnets ids"
}

output "private_subnet_ids" {
  value       = aws_subnet.private_subnet[*].id
  description = "return list with all private subnets ids"
}
