#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

prompt() {
  local label="$1"
  local default_value="$2"
  local value

  if [[ -n "$default_value" ]]; then
    read -r -p "$label [$default_value]: " value
    printf '%s' "${value:-$default_value}"
  else
    read -r -p "$label: " value
    printf '%s' "$value"
  fi
}

prompt_required() {
  local label="$1"
  local value

  while true; do
    read -r -p "$label: " value
    if [[ -n "$value" ]]; then
      printf '%s' "$value"
      return
    fi
    echo "This value is required" >&2
  done
}

prompt_matching() {
  local label="$1"
  local default_value="$2"
  local pattern="$3"
  local help_text="$4"
  local value

  while true; do
    value="$(prompt "$label" "$default_value")"
    if [[ "$value" =~ $pattern ]]; then
      printf '%s' "$value"
      return
    fi
    echo "$help_text" >&2
  done
}

yes_no() {
  local label="$1"
  local default_value="$2"
  local value
  local prompt_suffix="[y/N]"

  if [[ "$default_value" == "y" ]]; then
    prompt_suffix="[Y/n]"
  fi

  while true; do
    read -r -p "$label $prompt_suffix: " value
    value="${value:-$default_value}"
    case "$value" in
      y|Y|yes|YES) printf 'true'; return ;;
      n|N|no|NO) printf 'false'; return ;;
      *) echo "Please answer y or n" >&2 ;;
    esac
  done
}

hcl_list_from_csv() {
  local csv="$1"
  local output="["
  local first="true"
  local item
  local -a items

  IFS=',' read -ra items <<< "$csv"
  for item in "${items[@]}"; do
    item="$(printf '%s' "$item" | sed -E 's/^ +//; s/ +$//')"
    if [[ -z "$item" ]]; then
      continue
    fi
    if [[ "$first" == "false" ]]; then
      output+=", "
    fi
    output+="\"$item\""
    first="false"
  done

  output+="]"
  printf '%s' "$output"
}

hcl_string() {
  local value="$1"

  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '"%s"' "$value"
}

slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

echo "AWS Platform Starter Kit"
echo
echo "This script generates OpenTofu/Terraform variables. It does not apply infrastructure."
echo

company_name="$(prompt_required "Company or project name")"
environment="$(prompt_matching "Environment" "dev" '^[a-z]([a-z0-9-]{0,10}[a-z0-9])?$' "Use 1-12 lowercase letters, numbers, and hyphens")"
resource_prefix="$(prompt_matching "Resource prefix" "$(slugify "$company_name")" '^[a-z]([a-z0-9-]{0,22}[a-z0-9])?$' "Use 1-24 lowercase letters, numbers, and hyphens")"
owner="$(prompt "Owner tag" "platform")"
cost_center="$(prompt "CostCenter tag" "engineering")"
aws_region="$(prompt_matching "AWS region" "us-east-1" '^[a-z]{2}-[a-z]+-[0-9]+$' "Use an AWS region name like us-east-1")"

echo
echo "Select components"
enable_vpc="$(yes_no "Create VPC and subnets?" "y")"
enable_nat_gateway="$(yes_no "Create NAT Gateway? This can create notable cost." "n")"
enable_vpc_endpoints="$(yes_no "Create S3 and SSM VPC endpoints?" "y")"
enable_ec2_admin_host="$(yes_no "Create SSM-only EC2 admin host?" "n")"
enable_ecs_cluster="$(yes_no "Create ECS/Fargate cluster?" "y")"
enable_route53_zone="$(yes_no "Create Route 53 hosted zone for the domain?" "n")"
enable_cloudtrail="$(yes_no "Create basic CloudTrail trail?" "y")"
enable_budget_alert="$(yes_no "Create AWS budget alert?" "n")"

domain_name=""
if [[ "$enable_route53_zone" == "true" ]]; then
  domain_name="$(prompt_matching "Domain name for Route 53" "" '^([A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,}$' "Use a DNS name like example.com")"
fi

vpc_cidr_block="10.20.0.0/16"
availability_zones_hcl="[\"${aws_region}a\", \"${aws_region}b\"]"
if [[ "$enable_vpc" == "true" ]]; then
  vpc_cidr_block="$(prompt_matching "VPC CIDR block" "$vpc_cidr_block" '^([0-9]{1,3}\.){3}[0-9]{1,3}/(1[6-9]|20)$' "Use a private CIDR such as 10.20.0.0/16")"
  availability_zones="$(prompt "Availability zones, comma-separated" "${aws_region}a,${aws_region}b")"
  availability_zones_hcl="$(hcl_list_from_csv "$availability_zones")"
fi

admin_ami_id=""
admin_instance_type="t3.micro"
if [[ "$enable_ec2_admin_host" == "true" ]]; then
  admin_ami_id="$(prompt_required "AMI ID for SSM-only EC2 admin host")"
  admin_instance_type="$(prompt "Admin host instance type" "$admin_instance_type")"
fi

monthly_budget_usd="50"
budget_alert_email=""
if [[ "$enable_budget_alert" == "true" ]]; then
  monthly_budget_usd="$(prompt_matching "Monthly budget amount in USD" "$monthly_budget_usd" '^[0-9]+(\.[0-9]{1,2})?$' "Use a number like 50 or 125.50")"
  budget_alert_email="$(prompt_matching "Budget alert email" "" '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$' "Use a valid email address")"
fi

env_dir="$ROOT_DIR/environments/$environment"
mkdir -p "$env_dir"

if [[ ! -f "$env_dir/main.tf" ]]; then
  cp "$ROOT_DIR/environments/dev/"*.tf "$env_dir"/
fi

tfvars_file="$env_dir/terraform.tfvars"

cat > "$tfvars_file" <<EOF
company_name = $(hcl_string "$company_name")
domain_name = $(hcl_string "$domain_name")
environment = $(hcl_string "$environment")
resource_prefix = $(hcl_string "$resource_prefix")
owner = $(hcl_string "$owner")
cost_center = $(hcl_string "$cost_center")
aws_region = $(hcl_string "$aws_region")
availability_zones = $availability_zones_hcl
vpc_cidr_block = $(hcl_string "$vpc_cidr_block")

enable_vpc = $enable_vpc
enable_nat_gateway = $enable_nat_gateway
enable_vpc_endpoints = $enable_vpc_endpoints
enable_ec2_admin_host = $enable_ec2_admin_host
enable_ecs_cluster = $enable_ecs_cluster
enable_route53_zone = $enable_route53_zone
enable_cloudtrail = $enable_cloudtrail
enable_budget_alert = $enable_budget_alert

admin_ami_id = $(hcl_string "$admin_ami_id")
admin_instance_type = $(hcl_string "$admin_instance_type")
monthly_budget_usd = $(hcl_string "$monthly_budget_usd")
budget_alert_email = $(hcl_string "$budget_alert_email")
EOF

echo
echo "Generated: $tfvars_file"
echo
echo "Planned naming preview"
echo "VPC: ${resource_prefix}-${environment}-vpc-01"
echo "Public subnet A: ${resource_prefix}-${environment}-public-a"
echo "Private subnet A: ${resource_prefix}-${environment}-private-a"
echo "Isolated subnet A: ${resource_prefix}-${environment}-isolated-a"
echo "ECS cluster: ${resource_prefix}-${environment}-ecs"
echo "EC2 admin host: ${resource_prefix}-${environment}-admin-01"
echo
echo "Review notes"
echo "- Dedicated security groups are created per workload, avoid using the default security group"
echo "- SSM Session Manager is preferred over public SSH for admin access"
echo "- NAT Gateway and Route 53 hosted zones can create recurring cost"
echo "- Review the plan before applying"
echo
echo "Next commands"
echo "cd $env_dir"
echo "tofu init"
echo "tofu plan"
echo
echo "Terraform-compatible path"
echo "terraform init"
echo "terraform plan"
