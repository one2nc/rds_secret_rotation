output "db_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "rds_rotation_security_group_id" {
  value = aws_security_group.rotation_lambda_sg.id
}
