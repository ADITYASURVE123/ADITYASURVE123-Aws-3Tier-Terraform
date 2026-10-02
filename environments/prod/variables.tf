variable "project" {
  description = "Project name used as resource prefix."
  type        = string
  default     = "three-tier"
}

variable "environment" {
  description = "Environment name (dev or prod)."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (2)."
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "Private app subnet CIDRs (2)."
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "Private DB subnet CIDRs (2)."
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "One shared NAT (true) or one per AZ (false)."
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "ASG min size."
  type        = number
}

variable "asg_max_size" {
  description = "ASG max size."
  type        = number
}

variable "asg_desired_capacity" {
  description = "ASG desired capacity."
  type        = number
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "DB master username."
  type        = string
  default     = "dbadmin"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_multi_az" {
  description = "Enable RDS Multi-AZ."
  type        = bool
  default     = false
}

variable "db_backup_retention_days" {
  description = "RDS backup retention days."
  type        = number
  default     = 1
}

variable "db_deletion_protection" {
  description = "RDS deletion protection."
  type        = bool
  default     = false
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot on destroy."
  type        = bool
  default     = true
}
