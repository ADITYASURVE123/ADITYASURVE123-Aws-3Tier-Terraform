variable "name" {
  description = "Name prefix."
  type        = string
}

variable "secret_arns" {
  description = "Secrets Manager ARNs the instances may read."
  type        = list(string)
  default     = []
}
