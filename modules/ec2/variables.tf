variable "name_prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "ami_id" {
  description = "AMI ID."
  type        = string
}

variable "instance_type" {
  description = "Instance type."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}
