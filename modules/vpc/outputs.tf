output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = aws_subnet.private[*].id
}

output "isolated_subnet_ids" {
  description = "Isolated subnet IDs."
  value       = aws_subnet.isolated[*].id
}

output "subnet_cidr_map" {
  description = "Subnet CIDR layout by tier."
  value = {
    public   = local.public_subnet_cidrs
    private  = local.private_subnet_cidrs
    isolated = local.isolated_subnet_cidrs
  }
}
