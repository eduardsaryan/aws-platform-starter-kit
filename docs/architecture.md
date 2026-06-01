# Architecture Notes

## Baseline Shape

The starter kit creates one environment at a time. The default environment is `dev`.

Recommended account model for real use:

```text
security/logging account
shared services account
dev account
staging account
prod account
```

For this public starter, the Terraform environment starts with local state so readers can understand the structure before adding remote state or CI/CD.

## Network Layout

The VPC module creates:

- public subnets for load balancers or NAT gateways
- private subnets for application workloads
- isolated subnets for data-layer resources

Default guidance:

- do not put application instances directly in public subnets unless required
- prefer private subnets plus SSM for administration
- use VPC endpoints for AWS APIs where possible
- add NAT only when real internet egress is required

Default CIDR example:

```text
VPC: 10.20.0.0/16
```

With the default `/16`, the module creates `/20` subnets

For two AZs:

| Tier | AZ A | AZ B |
| --- | --- | --- |
| public | `10.20.0.0/20` | `10.20.16.0/20` |
| private | `10.20.64.0/20` | `10.20.80.0/20` |
| isolated | `10.20.128.0/20` | `10.20.144.0/20` |

The tier offsets are deliberate:

```text
public:   subnet indexes 0-3
private:  subnet indexes 4-7
isolated: subnet indexes 8-11
```

This leaves room for up to four AZs without overlapping tiers

Route table behavior:

- public subnets route internet traffic through the Internet Gateway
- private subnets get a default route only when NAT Gateway is enabled
- isolated subnets have no default route to the internet
- S3 gateway endpoint is attached to private and isolated route tables when enabled

## Component Selection

Components are controlled with boolean variables:

```hcl
enable_vpc               = true
enable_nat_gateway       = false
enable_vpc_endpoints     = true
enable_ec2_admin_host    = false
enable_ecs_cluster       = true
enable_route53_zone      = false
enable_cloudtrail        = true
enable_budget_alert      = false
```

## Naming

The root module builds names from:

```text
<resource_prefix>-<environment>-<component>
```

Example:

```text
acme-dev-vpc-01
acme-dev-ecs
acme-dev-admin-01
```

## Tagging

The root module applies a common tag set:

- `Project`
- `Company`
- `Environment`
- `Owner`
- `CostCenter`
- `ManagedBy`

Extend this list to match your organization's billing and compliance model.
