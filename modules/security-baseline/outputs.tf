output "cloudtrail_name" {
  description = "CloudTrail trail name."
  value       = var.enable_cloudtrail ? aws_cloudtrail.this[0].name : null
}
