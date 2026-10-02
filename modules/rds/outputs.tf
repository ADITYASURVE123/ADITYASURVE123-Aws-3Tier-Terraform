output "endpoint" {
  description = "DB hostname."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "DB port."
  value       = aws_db_instance.this.port
}

output "secret_arn" {
  description = "Secrets Manager ARN holding the master credentials."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
