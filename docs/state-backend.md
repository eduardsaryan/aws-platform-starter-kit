# State Backend

The checked-in environment starts with local state

That keeps the first run simple, but it is not the right shape for team work or long-lived infrastructure

Commit `.terraform.lock.hcl` after the first `terraform init` so provider versions stay predictable

## Options

| Option | Use when | Notes |
| --- | --- | --- |
| Local state | First review, throwaway test, learning run | Do not commit `terraform.tfstate` |
| S3 with native lockfile | Normal AWS-backed repo | Good default for this starter when running Terraform 1.10 or newer |
| S3 with DynamoDB lock table | Older Terraform setups or existing estates | Compatibility path, not the first choice for new Terraform repos |
| HCP Terraform | Team wants hosted runs, policy checks, remote state | Useful but outside this starter kit |
| GitLab managed state | GitLab is the main control plane | Good fit for self-hosted GitLab, use the HTTP backend pattern |

## Local State

Default behavior when no backend block exists

```text
environments/dev/terraform.tfstate
```

Good enough for:

- reading the repo
- first `terraform plan`
- single-user testing

Not good for:

- CI apply workflows
- shared ownership
- disaster recovery
- secrets exposure control

## S3 With Native Lockfile

Preferred AWS backend path for this repo

Requires Terraform 1.10 or newer

```hcl
terraform {
  backend "s3" {
    bucket       = "example-terraform-state"
    key          = "aws-platform-starter-kit/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

Bucket baseline:

- versioning enabled
- public access blocked
- server-side encryption
- restricted IAM access
- separate key path per environment

State bucket naming example:

```text
<account-or-org>-terraform-state-<region>
```

State key examples:

```text
aws-platform-starter-kit/dev/terraform.tfstate
aws-platform-starter-kit/staging/terraform.tfstate
aws-platform-starter-kit/prod/terraform.tfstate
```

## S3 With DynamoDB Locking

Use this only when an existing setup still depends on DynamoDB locking

```hcl
terraform {
  backend "s3" {
    bucket         = "example-terraform-state"
    key            = "aws-platform-starter-kit/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

For a new Terraform repo, prefer native S3 lockfile unless the team has a reason to keep DynamoDB

## Bootstrap Order

Backend resources should exist before this environment uses them

Common options:

- create the state bucket manually
- create it with a separate small bootstrap stack
- create it from an organization-level platform repo

Avoid creating the state bucket from the same state that depends on it
