# Partial backend config. Values are injected by scripts/init.sh (or the Jenkinsfile):
#   bucket / key / region / dynamodb_table / encrypt
terraform {
  backend "s3" {bucket         = "three-tier-v2-tfstate-911784620606"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "three-tier-v2-tf-locks"
  }
}
