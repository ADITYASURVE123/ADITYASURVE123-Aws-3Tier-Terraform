output "alb_sg_id" {
  description = "ALB security group ID."
  value       = aws_security_group.alb.id
}

output "app_sg_id" {
  description = "App security group ID."
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "DB security group ID."
  value       = aws_security_group.db.id
}
