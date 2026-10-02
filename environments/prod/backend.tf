# Partial backend config. Values are injected by scripts/init.sh (or the Jenkinsfile):
#   bucket / key / region / dynamodb_table / encrypt
terraform {
  backend "s3" {}
}
