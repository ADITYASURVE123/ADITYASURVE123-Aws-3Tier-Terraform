output "instance_profile_name" {
  description = "Instance profile to attach to EC2."
  value       = aws_iam_instance_profile.ec2.name
}

output "role_arn" {
  description = "EC2 role ARN."
  value       = aws_iam_role.ec2.arn
}
