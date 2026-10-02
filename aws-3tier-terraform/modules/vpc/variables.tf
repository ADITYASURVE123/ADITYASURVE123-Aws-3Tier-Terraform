variable "name" {
  description = "Name prefix for resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC."
  type        = string
}

variable "azs" {
  description = "Availability zones to spread subnets across."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets (one per AZ)."
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "CIDRs for private app subnets (one per AZ)."
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "CIDRs for private DB subnets (one per AZ)."
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "true = one shared NAT (cheap, dev). false = one NAT per AZ (HA, prod)."
  type        = bool
  default     = true
}
