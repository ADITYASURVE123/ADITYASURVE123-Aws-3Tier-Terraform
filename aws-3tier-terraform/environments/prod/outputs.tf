output "alb_dns_name" {
  description = "Open this URL in a browser."
  value       = module.alb.dns_name
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "asg_name" {
  description = "Auto Scaling group name."
  value       = module.compute.asg_name
}

output "db_endpoint" {
  description = "RDS endpoint (private)."
  value       = module.rds.endpoint
}

output "db_secret_arn" {
  description = "Secrets Manager ARN of the DB credentials."
  value       = module.rds.secret_arn
}
