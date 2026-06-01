# Security Notes

This starter kit favors conservative defaults.

## Security Groups

Dedicated security groups should be created per workload. Avoid relying on the default VPC security group because it makes ownership and access review unclear.

## Administration

Prefer SSM Session Manager over public SSH:

- no inbound SSH from the internet
- auditable access path
- IAM-controlled permissions
- easier emergency access without exposing port 22

If SSH is required, restrict it to trusted source ranges and document why.

## CloudTrail

CloudTrail is included as an optional baseline component. In a real organization, logs should normally go to a centralized logging/security account with restricted write-once style controls.

## Secrets

Do not put secrets in:

- Git
- `.tfvars`
- Terraform state without understanding exposure
- user data scripts
- CI logs

Use AWS Secrets Manager, SSM Parameter Store, or another secret manager.

## Terraform State

Local state is acceptable only for learning. For real use, configure:

- S3 backend
- encryption
- versioning
- locking
- restricted access

## Review Before Apply

The bootstrap script intentionally generates config and stops before applying. Review:

```bash
terraform plan
```

Then apply only after checking resource names, costs, network exposure, and IAM changes.
