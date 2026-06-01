output "zone_id" {
  description = "Hosted zone ID."
  value       = aws_route53_zone.this.zone_id
}

output "name_servers" {
  description = "Hosted zone name servers."
  value       = aws_route53_zone.this.name_servers
}
