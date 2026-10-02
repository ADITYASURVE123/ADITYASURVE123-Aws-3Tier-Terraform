variable "name" {
  description = "Name prefix."
  type        = string
}

variable "environment" {
  description = "Environment label shown on the web page."
  type        = string
}

variable "subnet_ids" {
  description = "Private app subnets for the ASG."
  type        = list(string)
}

variable "security_group_ids" {
  description = "App security groups."
  type        = list(string)
}

variable "instance_profile_name" {
  description = "IAM instance profile name."
  type        = string
}

variable "target_group_arns" {
  description = "ALB target groups to register with."
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "ASG minimum size."
  type        = number
}

variable "max_size" {
  description = "ASG maximum size."
  type        = number
}

variable "desired_capacity" {
  description = "ASG initial desired capacity."
  type        = number
}

variable "db_endpoint" {
  description = "Database endpoint displayed by the app."
  type        = string
}
