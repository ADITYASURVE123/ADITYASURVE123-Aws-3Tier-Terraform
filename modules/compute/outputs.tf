output "asg_name" {
  description = "Auto Scaling group name."
  value       = aws_autoscaling_group.this.name
}
