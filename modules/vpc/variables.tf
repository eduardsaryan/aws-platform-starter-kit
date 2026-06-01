variable "name_prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "cidr_block" {
  description = "VPC CIDR block."
  type        = string

  validation {
    condition     = can(cidrsubnet(var.cidr_block, 4, 0)) && can(regex("/(1[6-9]|20)$", var.cidr_block))
    error_message = "Use a valid VPC CIDR from /16 to /20"
  }
}

variable "availability_zones" {
  description = "Availability zones."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2 && length(var.availability_zones) <= 4
    error_message = "Use 2-4 availability zones"
  }
}

variable "enable_nat_gateway" {
  description = "Create NAT Gateway."
  type        = bool
}

variable "enable_vpc_endpoints" {
  description = "Create common VPC endpoints."
  type        = bool
}
