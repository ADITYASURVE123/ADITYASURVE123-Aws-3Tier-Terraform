#!/bin/bash
# Bootstraps Jenkins + Terraform + tflint + tfsec + checkov on Amazon Linux 2023.
set -euxo pipefail

# System updates and base dependencies
dnf update -y
dnf install -y git unzip jq wget python3-pip fontconfig java-17-amazon-corretto amazon-ssm-agent

# Enable and start SSM Agent
systemctl enable --now amazon-ssm-agent

# Jenkins LTS Repository Setup
mkdir -p /etc/yum.repos.d
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
dnf install -y jenkins

# Terraform (pinned to 1.9.8)
TF_VERSION=1.9.8
curl -fsSL -o /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"
unzip -o /tmp/terraform.zip -d /usr/local/bin
rm -f /tmp/terraform.zip

# tflint + tfsec
curl -fsSL https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
curl -fsSL -o /usr/local/bin/tfsec https://github.com/aquasecurity/tfsec/releases/latest/download/tfsec-linux-amd64
chmod +x /usr/local/bin/tfsec

# Checkov installation via pip
pip3 install --no-cache-dir checkov || true

# Start and enable Jenkins service
systemctl enable --now jenkins
