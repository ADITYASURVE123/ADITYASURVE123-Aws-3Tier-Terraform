variable "name" {
  description = "Name prefix."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets for the ALB."
  type        = list(string)
}

variable "security_group_ids" {
  description = "ALB security groups."
  type        = list(string)
}

variable "health_check_path" {
  description = "Target group health check path."
  type        = string
  default     = "/"
}

variable "deletion_protection" {
  description = "Enable ALB deletion protection."
  type        = bool
  default     = false
}
