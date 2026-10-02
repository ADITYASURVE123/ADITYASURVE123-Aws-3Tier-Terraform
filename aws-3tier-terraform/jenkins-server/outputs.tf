output "instance_id" {
  description = "Jenkins instance ID (use with SSM Session Manager)."
  value       = aws_instance.jenkins.id
}

output "jenkins_url" {
  description = "Jenkins UI URL."
  value       = "http://${var.use_elastic_ip ? aws_eip.jenkins[0].public_ip : aws_instance.jenkins.public_ip}:8080"
}

output "get_admin_password" {
  description = "Command to fetch the initial admin password."
  value       = "aws ssm start-session --target ${aws_instance.jenkins.id}  # then: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
}
