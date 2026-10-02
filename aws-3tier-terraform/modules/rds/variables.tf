variable "name" {
  description = "Name prefix."
  type        = string
}

variable "subnet_ids" {
  description = "Private DB subnet IDs."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups for the DB."
  type        = list(string)
}

variable "engine" {
  description = "DB engine (mysql or postgres)."
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "Engine version (major is enough; AWS picks the minor)."
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "DB instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Storage in GB."
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Initial database name."
  type        = string
}

variable "username" {
  description = "Master username (password is auto-managed in Secrets Manager)."
  type        = string
}

variable "multi_az" {
  description = "Enable Multi-AZ standby."
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Automated backup retention in days."
  type        = number
  default     = 1
}

variable "deletion_protection" {
  description = "Block accidental deletion."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on destroy."
  type        = bool
  default     = true
}
