output "dns_name" {
  description = "ALB DNS name."
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "Target group ARN for the ASG."
  value       = aws_lb_target_group.app.arn
}
