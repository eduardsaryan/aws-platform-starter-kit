locals {
  name_prefix = "${var.resource_prefix}-${var.environment}"

  common_tags = {
    Project     = "aws-platform-starter-kit"
    Company     = var.company_name
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  count  = var.enable_vpc ? 1 : 0
  source = "../../modules/vpc"

  name_prefix          = local.name_prefix
  cidr_block           = var.vpc_cidr_block
  availability_zones   = var.availability_zones
  enable_nat_gateway   = var.enable_nat_gateway
  enable_vpc_endpoints = var.enable_vpc_endpoints
}

module "security_baseline" {
  source = "../../modules/security-baseline"

  name_prefix       = local.name_prefix
  enable_cloudtrail = var.enable_cloudtrail
}

module "route53" {
  count  = var.enable_route53_zone && var.domain_name != "" ? 1 : 0
  source = "../../modules/route53"

  domain_name = var.domain_name
}

module "ecs" {
  count  = var.enable_ecs_cluster ? 1 : 0
  source = "../../modules/ecs"

  name_prefix = local.name_prefix
}

module "ec2_admin_host" {
  count  = var.enable_ec2_admin_host && var.enable_vpc && var.admin_ami_id != "" ? 1 : 0
  source = "../../modules/ec2"

  name_prefix   = local.name_prefix
  ami_id        = var.admin_ami_id
  instance_type = var.admin_instance_type
  subnet_id     = module.vpc[0].private_subnet_ids[0]
  vpc_id        = module.vpc[0].vpc_id
}

module "monitoring" {
  count  = var.enable_budget_alert ? 1 : 0
  source = "../../modules/monitoring"

  name_prefix        = local.name_prefix
  monthly_budget_usd = var.monthly_budget_usd
  alert_email        = var.budget_alert_email
}
