variable "name" {
  description = "Name prefix."
  type        = string
}

variable "vpc_id" {
  description = "VPC to create the security groups in."
  type        = string
}

variable "db_port" {
  description = "Database port (3306 MySQL, 5432 PostgreSQL)."
  type        = number
  default     = 3306
}
