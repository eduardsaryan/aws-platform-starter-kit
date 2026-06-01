variable "name_prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "monthly_budget_usd" {
  description = "Monthly budget amount in USD."
  type        = string
}

variable "alert_email" {
  description = "Email address for budget alerts."
  type        = string
}
