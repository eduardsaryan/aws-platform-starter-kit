variable "name_prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "enable_cloudtrail" {
  description = "Create CloudTrail trail."
  type        = bool
}
