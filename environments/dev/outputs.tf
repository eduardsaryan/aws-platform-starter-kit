output "vpc_id" {
  description = "VPC ID."
  value       = var.enable_vpc ? module.vpc[0].vpc_id : null
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = var.enable_vpc ? module.vpc[0].private_subnet_ids : []
}

output "subnet_cidr_map" {
  description = "Subnet CIDR layout by tier."
  value       = var.enable_vpc ? module.vpc[0].subnet_cidr_map : null
}

output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = var.enable_ecs_cluster ? module.ecs[0].cluster_name : null
}

output "route53_zone_id" {
  description = "Route 53 hosted zone ID."
  value       = var.enable_route53_zone && var.domain_name != "" ? module.route53[0].zone_id : null
}
