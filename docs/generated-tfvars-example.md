# Generated Tfvars Example

Example output from `./scripts/bootstrap.sh` for a small `dev` environment

```hcl
company_name = "Acme"
domain_name = ""
environment = "dev"
resource_prefix = "acme"
owner = "platform"
cost_center = "engineering"
aws_region = "us-east-1"
availability_zones = ["us-east-1a", "us-east-1b"]
vpc_cidr_block = "10.20.0.0/16"

enable_vpc = true
enable_nat_gateway = false
enable_vpc_endpoints = true
enable_ec2_admin_host = false
enable_ecs_cluster = true
enable_route53_zone = false
enable_cloudtrail = true
enable_budget_alert = false

admin_ami_id = ""
admin_instance_type = "t3.micro"
monthly_budget_usd = "50"
budget_alert_email = ""
```

This default shape creates the low-cost baseline pieces first:

- VPC and subnet layout
- S3 gateway endpoint and SSM interface endpoints
- ECS cluster
- CloudTrail bucket and trail

It skips resources that commonly create surprise cost or operational side effects:

- NAT Gateway
- Route 53 hosted zone
- EC2 admin host
- Budget alert without a real subscriber

Run `tofu plan` from the generated environment directory before applying

Terraform-compatible path:

```bash
terraform plan
```
