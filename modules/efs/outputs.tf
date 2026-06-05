output "efs_id" {
  value = aws_efs_file_system.fs.id
  description = "ID to mount in EC2 persistence"
}