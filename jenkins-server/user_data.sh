#!/bin/bash
# Bootstraps Jenkins + Terraform + tflint + tfsec + checkov on Amazon Linux 2023.
set -euxo pipefail

# System updates and base dependencies
dnf update -y
dnf install -y git unzip jq wget python3-pip fontconfig java-17-amazon-corretto amazon-ssm-agent

# Enable and start SSM Agent
systemctl enable --now amazon-ssm-agent

# Jenkins LTS Repository Setup
openjdk 21.0.8 2025-07-15
OpenJDK Runtime Environment (build 21.0.8+9-Debian-1)
OpenJDK 64-Bit Server VM (build 21.0.8+9-Debian-1, mixed mode, sharing)

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins

# Terraform (pinned to 1.9.8)
TF_VERSION=1.9.8
curl -fsSL -o /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"
unzip -o /tmp/terraform.zip -d /usr/local/bin
rm -f /tmp/terraform.zip

# tflint (Updated installer URL using 'main') + tfsec
curl -fsSL https://raw.githubusercontent.com/terraform-linters/tflint/main/install_linux.sh | bash
curl -fsSL -o /usr/local/bin/tfsec https://github.com/aquasecurity/tfsec/releases/latest/download/tfsec-linux-amd64
chmod +x /usr/local/bin/tfsec

# Checkov installation via pip
pip3 install --no-cache-dir checkov || true

# Start and enable Jenkins service
systemctl enable --now jenkins
