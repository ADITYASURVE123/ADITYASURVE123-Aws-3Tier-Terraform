variable "region" {
  description = "AWS region for the state bucket and lock table."
  type        = string
  default     = "ap-south-1"
}

variable "project" {
  description = "Project prefix. Must match PROJECT used by scripts/init.sh."
  type        = string
  default     = "three-tier-v2"
}

variable "force_destroy" {
  description = "Allow terraform destroy to delete a non-empty state bucket (learning only)."
  type        = bool
  default     = false
}
