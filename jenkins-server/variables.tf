variable "region" {
  description = "AWS region."
  type        = string
  default     = "ap-south-1"
}

variable "project" {
  description = "Name prefix."
  type        = string
  default     = "three-tier"
}

variable "instance_type" {
  description = "Jenkins instance type."
  type        = string
  default     = "c7i-flex.large"
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR form, e.g. 203.0.113.10/32 (curl checkip.amazonaws.com)."
  type        = string
}

variable "github_webhook_cidrs" {
  description = "GitHub hook CIDRs (see https://api.github.com/meta -> hooks). Leave empty to use SCM polling instead."
  type        = list(string)
  default     = []
}

variable "use_elastic_ip" {
  description = "Attach an Elastic IP so the URL survives stop/start (small hourly charge)."
  type        = bool
  default     = false
}
