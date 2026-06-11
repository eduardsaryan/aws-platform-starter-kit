# AWS Platform Starter Kit

Practical AWS infrastructure starter kit for small teams

It generates a reviewable AWS infrastructure baseline with consistent naming, tagging, network layout, and conservative security defaults

OpenTofu is the default path. Terraform-compatible commands are included because many teams still standardize on Terraform

No blind apply. The bootstrap script writes config, prints the naming preview, calls out cost-sensitive choices, and stops at a reviewable plan

## What It Can Create

- VPC with public, private, and isolated subnet options
- dedicated security groups instead of default security group usage
- S3 and SSM VPC endpoints
- optional SSM-only EC2 admin host
- optional ECS/Fargate cluster
- optional Route 53 hosted zone
- optional CloudTrail trail
- optional CloudWatch budget alert
- consistent tags and naming
- CI checks for OpenTofu validation and Terraform compatibility

## Default Settings

| Setting | Default |
| --- | --- |
| AWS region | `us-east-1` |
| environment | `dev` |
| VPC CIDR | `10.20.0.0/16` |
| public subnet A | `10.20.0.0/20` in `us-east-1a` |
| public subnet B | `10.20.16.0/20` in `us-east-1b` |
| private subnet A | `10.20.64.0/20` in `us-east-1a` |
| private subnet B | `10.20.80.0/20` in `us-east-1b` |
| isolated subnet A | `10.20.128.0/20` in `us-east-1a` |
| isolated subnet B | `10.20.144.0/20` in `us-east-1b` |
| NAT Gateway | disabled |
| VPC endpoints | enabled |
| EC2 admin host | disabled |
| ECS/Fargate cluster | enabled |
| Route 53 hosted zone | disabled |
| CloudTrail trail | enabled |
| budget alert | disabled |

## Prerequisites

Use a test AWS account. Do not start with a production account

Required local tools:

- OpenTofu 1.10 or newer
- AWS CLI
- Terraform 1.10 or newer only if you want to check compatibility

Required AWS access:

- an AWS account you can create test resources in
- permission to create the resources you enable during bootstrap
- one working AWS credential path:
  - AWS SSO profile
  - IAM access key in environment variables
  - IAM access key configured with `aws configure`

## Install Local Tools

### macOS

Install tools with Homebrew:

```bash
brew install opentofu
brew install awscli
```

Optional Terraform compatibility path:

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

Check tools:

```bash
tofu version
aws --version
terraform version
```

If you are not using Terraform, skip the `terraform version` check

### Debian or Ubuntu

Install base packages:

```bash
sudo apt-get update
sudo apt-get install -y curl gpg ca-certificates unzip
```

Install OpenTofu from the official package installer:

```bash
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
./install-opentofu.sh --install-method deb
rm -f install-opentofu.sh
```

Install the AWS CLI:

```bash
arch="$(uname -m)"
case "${arch}" in
  x86_64) aws_arch="x86_64" ;;
  aarch64|arm64) aws_arch="aarch64" ;;
  *) echo "unsupported AWS CLI architecture: ${arch}" >&2; exit 1 ;;
esac
curl "https://awscli.amazonaws.com/awscli-exe-linux-${aws_arch}.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip
```

Optional Terraform compatibility path:

```bash
sudo apt-get update
sudo apt-get install -y gnupg software-properties-common wget
. /etc/os-release
codename="${UBUNTU_CODENAME:-${VERSION_CODENAME}}"
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${codename} main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update
sudo apt-get install -y terraform
```

Check tools:

```bash
tofu version
aws --version
terraform version
```

If you are not using Terraform, skip the `terraform version` check

## AWS Credentials

Choose one credential path

### AWS SSO

Configure the profile:

```bash
aws configure sso
```

Log in:

```bash
aws sso login --profile my-sso-profile
```

Use the profile for OpenTofu commands:

```bash
export AWS_PROFILE=my-sso-profile
aws sts get-caller-identity
```

### Access Keys

Configure a local AWS CLI profile:

```bash
aws configure --profile test-account
export AWS_PROFILE=test-account
aws sts get-caller-identity
```

Or use environment variables:

```bash
export AWS_ACCESS_KEY_ID=replace-me
export AWS_SECRET_ACCESS_KEY=replace-me
export AWS_REGION=us-east-1
aws sts get-caller-identity
```

The `aws sts get-caller-identity` command should show the account you expect before you run `tofu plan`

## First Plan

Generate config:

```bash
./scripts/bootstrap.sh
```

The script creates an environment-specific `terraform.tfvars` file

If the selected environment directory does not exist yet, the script copies the root HCL files from `environments/dev/` and writes a new `terraform.tfvars`

For the first test, keep these low-cost choices:

- NAT Gateway disabled
- EC2 admin host disabled
- Route 53 hosted zone disabled
- budget alert disabled unless you have a real alert email

Run OpenTofu checks:

```bash
cd environments/dev
tofu init -backend=false
tofu fmt -recursive ../..
tofu validate
tofu plan
```

Expected result:

- `tofu validate` reports success
- `tofu plan` completes without provider or syntax errors
- the plan shows only the components selected during bootstrap
- no infrastructure is created yet

Do not run `tofu apply` during the first test

Input rules: [docs/input-parameters.md](docs/input-parameters.md)

Generated output example: [docs/generated-tfvars-example.md](docs/generated-tfvars-example.md)

## Terraform Compatibility

The same HCL can also be checked with Terraform:

```bash
cd environments/dev
terraform init
terraform plan
```

Do not maintain separate OpenTofu and Terraform folders. Compatibility should be proven by CI and documented command paths, not duplicated code

## Apply

Only apply after reviewing the plan:

```bash
cd environments/dev
tofu apply
```

## Cleanup

Destroy resources from the same environment directory:

```bash
cd environments/dev
tofu destroy
```

Check the AWS console after cleanup if an apply or destroy was interrupted

If `tofu plan` fails before showing a plan, check:

- AWS credentials are active
- selected AWS region is correct
- IAM permissions allow the selected resources
- `terraform.tfvars` exists in the environment directory

## Network Layout

Default VPC CIDR:

```text
10.20.0.0/16
```

Default two-AZ subnet split:

| Tier | AZ A | AZ B |
| --- | --- | --- |
| public | `10.20.0.0/20` | `10.20.16.0/20` |
| private | `10.20.64.0/20` | `10.20.80.0/20` |
| isolated | `10.20.128.0/20` | `10.20.144.0/20` |

Private subnets only get internet egress when NAT Gateway is enabled

More detail: [docs/architecture.md](docs/architecture.md)

## State Backend

No remote backend is enabled by default, so the state path is an explicit choice

For shared or long-lived infrastructure, use remote state. The recommended AWS path is S3 with native lockfile support on OpenTofu 1.10 or newer

Backend options: [docs/state-backend.md](docs/state-backend.md)

## Example Naming

For company `Acme`, environment `dev`, and prefix `acme`, resources follow names like:

```text
VPC: acme-dev-vpc-01
Public subnet A: acme-dev-public-a
Private subnet A: acme-dev-private-a
ECS cluster: acme-dev-ecs
EC2 admin host: acme-dev-admin-01
```

## Design Principles

- Generate config first, then review a plan
- Use descriptive names
- Tag everything consistently
- Prefer private subnets for workloads
- Prefer SSM Session Manager over public SSH
- Create dedicated security groups per workload
- Keep optional components explicit
- Make cleanup documented and predictable

## Cost Warning

Some resources can create recurring costs, especially:

- NAT Gateway
- EC2 instances
- Route 53 hosted zones
- CloudWatch metrics/logs
- AWS Budgets is usually low-cost/free depending on account usage, but check AWS pricing

Always run `tofu plan` before applying and review what will be created

## Repository Layout

```text
environments/
  dev/
modules/
  vpc/
  ec2/
  ecs/
  monitoring/
  route53/
  security-baseline/
scripts/
docs/
```

## Production Notes

This is a starter kit, not a full production landing zone

For production, consider:

- separate AWS accounts per environment
- remote state with encryption and locking
- CI plan/apply workflow with approval gates
- centralized logs
- IAM Identity Center for human access
- stricter SCPs and AWS Organizations structure
- tested backup and restore procedures
- explicit incident runbooks

Related notes:

- [docs/security-notes.md](docs/security-notes.md)
- [docs/architecture.md](docs/architecture.md)

## License

MIT
