# Interview Prep

## 30 Interview Questions

### Terraform
1. **What is Terraform state and why remote?** It maps config to real resources. Remote state (S3) is shared, durable, versioned, and encrypted, and it enables locking. Local state is lost and cannot be shared.
2. **How does state locking work?** Before writing state, Terraform writes a `LockID` item to DynamoDB with a conditional put. A second run fails until the lock is released. It prevents concurrent applies from corrupting state.
3. **Stuck lock?** Confirm no run is active, then `terraform force-unlock <ID>`.
4. **Why modules?** Reuse, consistent standards, smaller blast radius, and testable units. Inputs are variables, outputs expose IDs, and versions are pinned.
5. **What is drift and how do you handle it?** Real infrastructure differs from state or config because of manual changes. Run `terraform plan` (or `-refresh-only`) to detect it. Then revert via apply, or import and update code. Restrict console access to prevent it.
6. **Lifecycle rules?** `create_before_destroy` (used on SGs, LT, target group), `prevent_destroy` (protects critical resources), `ignore_changes` (used on ASG desired_capacity so autoscaling wins).
7. **count vs for_each?** `count` is index-based, so removing item 0 shifts the rest and forces recreation. `for_each` uses stable keys, so it is safer for sets and maps. I use `count` for AZ-indexed subnets and `for_each` for IAM policy attachments.
8. **NAT Gateway vs Internet Gateway?** An IGW gives two-way internet access to public subnets (resources need public IPs). A NAT gateway gives outbound-only access to private subnets and sits in a public subnet with an EIP.
9. **Security Group vs NACL?** SG: instance-level, stateful, allow rules only. NACL: subnet-level, stateless, allow and deny rules with ordering. I use SG references for the tier chain.
10. **Workspaces vs folders for environments?** Workspaces share code and backend config and are easy to run in the wrong workspace. Folders with separate state keys give clearer isolation and per-env config, which I chose.
11. **Secrets in Terraform?** Never hardcode. I use `manage_master_user_password` so RDS keeps the password in Secrets Manager. State can still hold sensitive values, so the bucket is encrypted and access is restricted.
12. **How do you pin versions?** `required_version`, `required_providers` with `~>`, and a committed `.terraform.lock.hcl`.
13. **Data source vs resource?** A data source reads existing things (AZs, AMI). A resource creates and manages them.
14. **Implicit vs explicit dependencies?** References create implicit graph edges. `depends_on` is for hidden dependencies (NAT depends on the IGW).
15. **How do you bring existing resources under Terraform?** `terraform import` or `import {}` blocks, then write matching config and confirm a clean plan. `moved` blocks handle refactors without recreation.
16. **plan vs apply and `-out`?** Plan shows the diff. Saving with `-out` makes apply execute exactly what was reviewed, which matters in CI with approvals.

### Jenkins
17. **Declarative vs scripted pipeline?** Declarative: structured, with validation, `post`, `when`, and `options`. Scripted: full Groovy, more flexible, easier to get wrong. I use declarative and drop into `script {}` where needed.
18. **What is a Multibranch Pipeline?** It auto-discovers branches and PRs containing a Jenkinsfile and creates a job for each. That gives per-branch behavior via `when { branch 'main' }`.
19. **Agents and nodes?** The controller schedules; agents (nodes) run builds. Executors set parallelism. Production practice: keep builds off the controller and use ephemeral Docker/K8s agents.
20. **Managing credentials?** The Credentials plugin (encrypted, masked in logs) used through `credentials()` or `withCredentials`. For AWS, I use an instance profile so there are no stored keys.
21. **Webhooks vs polling?** Webhooks trigger instantly, cost nothing, and require Jenkins to be reachable. Polling is a fallback for private Jenkins.
22. **The `input` step?** It pauses the pipeline for human approval. I use it for prod and destroy, with a timeout, so it only applies the reviewed plan artifact.
23. **Shared libraries?** Central Groovy code in `vars/` and `src/` loaded with `@Library`. It removes duplication across repos and enforces standards.
24. **How do you secure Jenkins?** Enable auth/RBAC, disable anonymous access, keep CSRF protection on, restrict the SG, use HTTPS via a reverse proxy, update plugins, keep builds off the controller, and use least-privilege IAM.
25. **Jenkins vs GitHub Actions?** Jenkins: self-hosted, highly customizable, plugin-rich, and you maintain it. Actions: managed, YAML, tightly integrated with GitHub, and less operational overhead.
26. **Why an instance profile rather than access keys?** Credentials are temporary, auto-rotated, and never stored or leaked. Access is scoped to the role.
27. **How do you prevent two pipelines applying at once?** `disableConcurrentBuilds()` plus the DynamoDB state lock and `-lock-timeout`.
28. **`post` blocks?** `always`, `success`, `failure` run after stages. I use them for cleanup and notifications.
29. **How does the security scan gate deploys?** `tfsec --minimum-severity HIGH` exits non-zero and fails the build before plan. False positives are suppressed with an inline ignore that carries a reason.
30. **How do PRs differ from main?** PRs and feature branches run fmt, validate, lint, scan, and plan only. `when { branch 'main' }` guards approval and apply.

## 5 Resume Bullets
- Designed and deployed a 3-tier AWS architecture (VPC, ALB, ASG, Multi-AZ RDS) with Terraform across 2 AZs, using 6 reusable modules and 2 isolated environments.
- Built a Jenkins declarative multibranch pipeline (fmt, validate, tflint, tfsec, plan, approval, apply) that cut manual infrastructure deployment steps from about 15 to 1 click.
- Eliminated hardcoded secrets and SSH keys using RDS-managed Secrets Manager passwords, SSM Session Manager, and IAM instance profiles, and removed all long-lived credentials from CI.
- Implemented S3 + DynamoDB remote state with versioning, encryption, and locking, preventing concurrent-apply corruption and enabling state rollback.
- Enforced security gates in CI (tfsec fail on HIGH/CRITICAL, IMDSv2, encrypted storage, least-privilege SG chaining), and cut dev cost with a single-NAT design and scripted teardown.

(Replace the numbers with your own measured results before using them.)

## 2-Minute Project Script
"I built a production-style three-tier application on AWS entirely with Terraform. The network is a VPC across two availability zones with public, private-app, and private-database subnets. An Application Load Balancer sits in the public subnets and forwards to an Auto Scaling group of EC2 instances in private subnets, which talk to a MySQL RDS instance in isolated database subnets. Security groups chain ALB to app to DB, so nothing else can reach the database.

There are no SSH keys: instances use an IAM role with SSM Session Manager, and the database password is created and rotated by RDS in Secrets Manager, so no secrets exist in code. Terraform state lives in S3 with versioning and encryption, with DynamoDB locking.

The code is split into six reusable modules, and dev and prod are separate folders with their own state and tfvars. Dev uses one NAT and single-AZ RDS to save cost, and prod uses a NAT per AZ and Multi-AZ RDS.

For delivery, I run Jenkins on its own EC2 instance with an instance profile, so no AWS keys are stored. A multibranch declarative pipeline is triggered by GitHub webhooks: format check, init, validate, tflint, tfsec failing on high severity, then plan with the plan archived. Pull requests stop at plan. On main, prod requires a manual approval and then applies the exact saved plan. The biggest lessons were state locking, keeping the pipeline secure, and controlling cost."

## 3 Improvements
1. **Jenkins agents on Docker/Kubernetes** for ephemeral, isolated build agents with pinned tool images, and remove tooling from the controller.
2. **Edge and security hardening:** HTTPS with ACM and Route 53, CloudFront in front of the ALB, AWS WAF managed rules, VPC endpoints for SSM and S3 to tighten egress, and VPC flow logs.
3. **Observability and modernization:** Prometheus/Grafana or CloudWatch dashboards and alarms (ALB 5xx, ASG CPU, RDS storage), then move the app tier to ECS Fargate or EKS.
