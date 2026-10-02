terraform {
  backend "s3" {
    bucket = "three-tier-v2-tfstate-911784620606"
    key    = "dev/terraform.tfstate"
    region = "ap-south-1"
  }
}
