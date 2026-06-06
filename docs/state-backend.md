# State Backend

No remote backend is enabled in the checked-in environment.

That keeps the starter neutral. Choose a backend before using this for shared or long-lived infrastructure.

OpenTofu is the default path. Terraform-compatible notes are included where the behavior matters.

Commit `.terraform.lock.hcl` only after choosing the tool and running init in the environment that owns the configuration.

## Options

| Option | Use when | Notes |
| --- | --- | --- |
| S3 with native lockfile | Normal AWS-backed workflow | Preferred path for this starter |
| S3 with DynamoDB lock table | Existing estates that still use DynamoDB locking | Compatibility path |
| GitLab managed state | GitLab is the main control plane | Good fit for self-hosted GitLab, use the HTTP backend pattern |
| No backend block | First review or CI syntax validation | Do not use for shared apply workflows |

## S3 With Native Lockfile

Preferred AWS backend path for this repo.

Requires OpenTofu 1.10 or newer. Terraform compatibility also expects Terraform 1.10 or newer.

```hcl
terraform {
  backend "s3" {
    bucket       = "example-iac-state"
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
<account-or-org>-iac-state-<region>
```

State key examples:

```text
aws-platform-starter-kit/dev/terraform.tfstate
aws-platform-starter-kit/staging/terraform.tfstate
aws-platform-starter-kit/prod/terraform.tfstate
```

## S3 With DynamoDB Locking

Use this only when an existing setup still depends on DynamoDB locking.

```hcl
terraform {
  backend "s3" {
    bucket         = "example-iac-state"
    key            = "aws-platform-starter-kit/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "iac-locks"
  }
}
```

For new AWS-backed workflows, prefer native S3 lockfile unless the team has a reason to keep DynamoDB.

## GitLab Managed State

Use this when GitLab is the main control plane for the repo and CI.

Keep credentials in CI variables, not in backend files.

```hcl
terraform {
  backend "http" {}
}
```

Pass backend settings during init from GitLab CI or another controlled runner.

## Bootstrap Order

Backend resources should exist before this environment uses them.

Common options:

- create the state bucket through an organization-level platform repo
- create it with a separate small bootstrap stack
- create it manually with documented settings if the environment is temporary

Avoid creating the state bucket from the same state that depends on it.
