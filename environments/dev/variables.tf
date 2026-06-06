variable "company_name" {
  description = "Company or organization name used for tags."
  type        = string
}

variable "domain_name" {
  description = "Domain name used by optional Route 53 resources."
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name, for example dev, staging, or prod."
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z]([a-z0-9-]{0,10}[a-z0-9])?$", var.environment))
    error_message = "Use 1-12 lowercase letters, numbers, and hyphens"
  }
}

variable "resource_prefix" {
  description = "Short prefix used in resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z]([a-z0-9-]{0,22}[a-z0-9])?$", var.resource_prefix))
    error_message = "Use 1-24 lowercase letters, numbers, and hyphens"
  }
}

variable "owner" {
  description = "Owner tag value."
  type        = string
  default     = "platform"
}

variable "cost_center" {
  description = "CostCenter tag value."
  type        = string
  default     = "engineering"
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "Use an AWS region name like us-east-1"
  }
}

variable "availability_zones" {
  description = "Availability zones used by the VPC module."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]

  validation {
    condition     = length(var.availability_zones) >= 2 && length(var.availability_zones) <= 4
    error_message = "Use 2-4 availability zones"
  }
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = can(cidrsubnet(var.vpc_cidr_block, 4, 0)) && can(regex("/(1[6-9]|20)$", var.vpc_cidr_block))
    error_message = "Use a valid VPC CIDR from /16 to /20"
  }
}

variable "enable_vpc" {
  description = "Create VPC and subnets."
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Create one NAT Gateway for private subnet egress."
  type        = bool
  default     = false
}

variable "enable_vpc_endpoints" {
  description = "Create S3 and SSM VPC endpoints."
  type        = bool
  default     = true
}

variable "enable_ec2_admin_host" {
  description = "Create SSM-only EC2 admin host."
  type        = bool
  default     = false
}

variable "enable_ecs_cluster" {
  description = "Create ECS/Fargate cluster."
  type        = bool
  default     = true
}

variable "enable_route53_zone" {
  description = "Create Route 53 public hosted zone."
  type        = bool
  default     = false
}

variable "enable_cloudtrail" {
  description = "Create a basic CloudTrail trail."
  type        = bool
  default     = true
}

variable "enable_budget_alert" {
  description = "Create AWS budget alert."
  type        = bool
  default     = false
}

variable "admin_ami_id" {
  description = "AMI ID for the optional EC2 admin host. Leave empty to skip."
  type        = string
  default     = ""
}

variable "admin_instance_type" {
  description = "Instance type for the optional EC2 admin host."
  type        = string
  default     = "t3.micro"
}

variable "monthly_budget_usd" {
  description = "Monthly budget amount in USD."
  type        = string
  default     = "50"

  validation {
    condition     = can(regex("^[0-9]+(\\.[0-9]{1,2})?$", var.monthly_budget_usd))
    error_message = "Use a number like 50 or 125.50"
  }
}

variable "budget_alert_email" {
  description = "Email address for budget alerts."
  type        = string
  default     = ""

  validation {
    condition     = var.budget_alert_email == "" || can(regex("^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$", var.budget_alert_email))
    error_message = "Use a valid email address or leave it empty"
  }
}
