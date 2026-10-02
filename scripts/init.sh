#!/usr/bin/env bash
# Usage: bash scripts/init.sh <dev|prod>
# Initialises the S3 backend using names derived from your AWS account ID,
# so no bucket names are hardcoded in Git.
set -euo pipefail
ENV="${1:?usage: bash scripts/init.sh <dev|prod>}"
PROJECT="${PROJECT:-three-tier}"
REGION="${AWS_REGION:-ap-south-1}"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

terraform -chdir="$ROOT/environments/$ENV" init -input=false -reconfigure \
  -backend-config="bucket=${PROJECT}-tfstate-${ACCOUNT_ID}" \
  -backend-config="key=${ENV}/terraform.tfstate" \
  -backend-config="region=${REGION}" \
  -backend-config="dynamodb_table=${PROJECT}-tf-locks" \
  -backend-config="encrypt=true"
