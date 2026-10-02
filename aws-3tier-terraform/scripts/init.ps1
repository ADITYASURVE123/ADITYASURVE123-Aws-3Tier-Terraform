# Usage: .\scripts\init.ps1 -Environment dev
param([Parameter(Mandatory = $true)][ValidateSet('dev', 'prod')][string]$Environment)
$Project = if ($env:PROJECT) { $env:PROJECT } else { 'three-tier' }
$Region  = if ($env:AWS_REGION) { $env:AWS_REGION } else { 'us-east-1' }
$Account = aws sts get-caller-identity --query Account --output text
terraform "-chdir=$PSScriptRoot/../environments/$Environment" init -input=false -reconfigure `
  "-backend-config=bucket=$Project-tfstate-$Account" `
  "-backend-config=key=$Environment/terraform.tfstate" `
  "-backend-config=region=$Region" `
  "-backend-config=dynamodb_table=$Project-tf-locks" `
  "-backend-config=encrypt=true"
