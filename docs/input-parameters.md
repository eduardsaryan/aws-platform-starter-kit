# Input Parameters

The starter kit separates inputs into three groups:

- required
- optional with safe defaults
- conditionally required based on selected components

The bootstrap script generates `terraform.tfvars` and stops before `terraform apply`.

Example generated output: [generated-tfvars-example.md](generated-tfvars-example.md)

## Required

| Input | Why |
| --- | --- |
| `company_name` | Used for tags and project identity |

## Optional With Defaults

| Input | Default | Why |
| --- | --- | --- |
| `environment` | `dev` | Keeps first run low-risk and clearly non-production |
| `resource_prefix` | slugified `company_name` | Used in AWS resource names |
| `owner` | `platform` | Ownership tag |
| `cost_center` | `engineering` | Cost allocation tag |
| `aws_region` | `us-east-1` | AWS provider region |
| `vpc_cidr_block` | `10.20.0.0/16` | VPC CIDR when VPC is enabled, use `/16` to `/20` |
| `availability_zones` | `<region>a`, `<region>b` | Two-AZ starter layout |
| `admin_instance_type` | `t3.micro` | EC2 admin host size |
| `monthly_budget_usd` | `50` | Budget threshold |

## Component Toggles

| Input | Default | Notes |
| --- | --- | --- |
| `enable_vpc` | `true` | Creates VPC and subnets |
| `enable_nat_gateway` | `false` | Disabled by default because NAT Gateway can be expensive |
| `enable_vpc_endpoints` | `true` | Keeps AWS service traffic private where supported |
| `enable_ec2_admin_host` | `false` | Disabled unless an admin host is needed |
| `enable_ecs_cluster` | `true` | Creates ECS/Fargate cluster |
| `enable_route53_zone` | `false` | Disabled to avoid accidental DNS changes/cost |
| `enable_cloudtrail` | `true` | Security baseline should be on by default |
| `enable_budget_alert` | `false` | Disabled until a real email is provided |

## Conditionally Required

| Input | Required When | Why |
| --- | --- | --- |
| `domain_name` | `enable_route53_zone = true` | Route 53 hosted zone needs a domain |
| `admin_ami_id` | `enable_ec2_admin_host = true` | EC2 instance needs an AMI |
| `budget_alert_email` | `enable_budget_alert = true` | Budget alert without a subscriber is not useful |

## Intentional Defaults

Defaults are conservative:

- `dev` environment first
- no NAT Gateway by default
- no Route 53 hosted zone by default
- no EC2 admin host by default
- SSM-only admin host pattern if EC2 is enabled
- CloudTrail enabled by default
- Terraform plan review before apply
