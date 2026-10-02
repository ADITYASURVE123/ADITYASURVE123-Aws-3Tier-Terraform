# Phase-by-Phase Guide

Each phase lists what it builds, why, commands, verification, and common errors.

## Phase 1: Remote state bootstrap (`bootstrap/`)
**Builds:** S3 bucket (versioning, AES256, public-access block, TLS-only policy) and DynamoDB table with hash key `LockID`.
**Why:** State is the source of truth. Local state is lost, unshared, and unlocked. S3 gives durability and versioning (rollback), DynamoDB gives a lock so two applies cannot corrupt state. Bootstrap uses local state because the backend cannot store itself before it exists.
```bash
cd bootstrap && terraform init && terraform apply
```
**Verify:** S3 console shows `three-tier-tfstate-<account-id>`. Versioning is enabled. DynamoDB has `three-tier-tf-locks`.
**Errors:** `BucketAlreadyExists` means change the `project` variable. `AccessDenied` means check `aws sts get-caller-identity`.

## Phase 2: VPC (`modules/vpc`)
**Builds:** VPC, 2 public, 2 private-app, 2 private-db subnets, IGW, NAT (one in dev, one per AZ in prod), route tables.
**Why:** Public subnets route `0.0.0.0/0` to the IGW. App subnets route to NAT (outbound only). DB subnets have no internet route. `count` builds per-AZ resources. `single_nat_gateway` trades HA for cost.
**Verify:** VPC console, Resource map. Check each route table's routes.

## Phase 3: Security groups (`modules/security-groups`)
**Why:** SGs reference SGs (not CIDRs), so only the ALB can reach the app and only the app can reach the DB. SGs are stateful. Separate `aws_vpc_security_group_*_rule` resources avoid circular dependencies between SGs.
**Verify:** DB SG inbound shows source = app SG, port 3306.

## Phase 4: IAM (`modules/iam`)
**Builds:** EC2 role, instance profile, `AmazonSSMManagedInstanceCore`, CloudWatch agent policy (via `for_each`), and read access to only the DB secret.
**Why:** SSM Session Manager replaces SSH: no key pairs, no port 22, and every session is audited.

## Phase 5: Compute (`modules/compute`)
**Builds:** Launch template (latest AL2023 AMI via data source, IMDSv2 required, encrypted gp3, user_data web page), ASG in private subnets with ELB health checks, rolling instance refresh, CPU target-tracking policy at 60%.
**Why:** Launch template changes create a new version, and `instance_refresh` rolls instances safely. `ignore_changes = [desired_capacity]` stops Terraform from fighting autoscaling.

## Phase 6: ALB (`modules/alb`)
Internet-facing ALB in public subnets, target group with `/` health check, HTTP:80 listener. In production add ACM + HTTPS and redirect 80 to 443.

## Phase 7: RDS (`modules/rds`)
**Why:** `manage_master_user_password = true` makes RDS create and rotate the password in Secrets Manager. It never appears in code or tfvars. Storage is encrypted, the DB is not public, and Multi-AZ is a variable (on in prod only).
**Note:** RDS takes 5 to 10 minutes to create.

## Phase 8: Environments and modularization
`environments/dev` and `prod` contain identical wiring and differ only in `*.tfvars` and the state key (`dev/terraform.tfstate` vs `prod/terraform.tfstate`).
```bash
bash scripts/init.sh dev
terraform -chdir=environments/dev plan -var-file=dev.tfvars
terraform -chdir=environments/dev apply -var-file=dev.tfvars
```
**Verify:** Open the `alb_dns_name` output. Refresh a few times to see different instance IDs and AZs. EC2 console shows instances with no public IPs. Target group shows "healthy".
**Errors:**
- `Error acquiring the state lock`: another run is active, or one crashed. Run `terraform force-unlock <ID>` only if sure.
- `NoCredentialProviders` / `ExpiredToken`: re-run `aws configure`.
- Targets `unhealthy`: give it 3 minutes for user_data. Check the app SG allows the ALB SG on port 80. Use SSM to read `/var/log/cloud-init-output.log`.
- `Backend initialization required`: run `scripts/init.sh` again.
- `VpcLimitExceeded` / `AddressLimitExceeded`: delete unused VPCs or Elastic IPs.

## Phase 9: Jenkins server (`jenkins-server/`)
```bash
curl checkip.amazonaws.com        # your IP
cd jenkins-server
terraform init
terraform apply -var "my_ip_cidr=YOUR.IP.HERE/32"
```
Then follow the `get_admin_password` output (SSM session, then `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`). Open `jenkins_url`, unlock, install suggested plugins.
**Extra plugins:** Pipeline (workflow-aggregator), Multibranch (workflow-multibranch), Git, GitHub, GitHub Branch Source, Credentials, AnsiColor, Timestamper, Mailer or Slack Notification.
**Check tools:** SSM into the box and run `terraform version; tflint --version; tfsec --version`. Install takes a few minutes after boot (`tail /var/log/cloud-init-output.log`).
**Errors:** UI unreachable means your IP changed (update `my_ip_cidr`) or Jenkins is still booting. `terraform: not found` in a build means the user_data install failed. Check cloud-init logs.
**Cost:** stop the instance when not in use. Public IP changes on restart unless `use_elastic_ip = true`.

## Phase 10: Jenkinsfile pipeline
1. Push this repo to GitHub.
2. Jenkins: New Item, Multibranch Pipeline, Branch Source = GitHub (add a GitHub PAT under Credentials as "Username with password" or "Secret text"), Build Configuration = by Jenkinsfile.
3. Run "Scan Multibranch Pipeline Now". `main` builds once and registers the parameters (ENVIRONMENT, ACTION, RUN_INFRACOST).
4. Use "Build with Parameters".

**Behaviour:** Feature branches and PRs stop after Plan. `main` continues to Apply. Prod (or any destroy) pauses at the Approval `input` step and shows the archived plan.
**Errors:**
- `Unable to locate credentials`: the Jenkins instance profile is missing, or IMDS is blocked.
- `tfsec` fails the build: read the finding. Fix it, or add `#tfsec:ignore:<rule-id>` with a justification comment.
- `fmt -check` fails: run `terraform fmt -recursive` locally and commit.
- `No such DSL method 'ansiColor'` or `timestamps`: plugin missing.
- Plugin/agent offline: check the executor and disk space.

## Phase 11: Webhook and approvals
1. `terraform apply -var 'github_webhook_cidrs=[...]'` using the `hooks` ranges from https://api.github.com/meta (or skip webhooks and enable "Scan periodically" in the job).
2. GitHub repo, Settings, Webhooks: Payload URL `http://<jenkins-ip>:8080/github-webhook/`, content type `application/json`, events: push and pull requests.
3. In the multibranch job, keep GitHub Branch Source. It handles hook events.
4. Push a change on a branch. A build should start within seconds. Open a PR and check that it runs plan only.

**Webhook not firing?** GitHub, Webhooks, Recent Deliveries shows the status code. A timeout means the SG blocks GitHub. A 403 means the URL is wrong or a CSRF proxy is in play. Jenkins IP changed? Update the URL.

## Final cleanup checklist
- [ ] Dev (and prod) destroyed
- [ ] Jenkins instance stopped or destroyed
- [ ] Bootstrap destroyed last (optional)
- [ ] Billing dashboard checked next day
