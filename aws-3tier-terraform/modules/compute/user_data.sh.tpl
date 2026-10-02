#!/bin/bash
set -euxo pipefail
dnf install -y httpd

# IMDSv2 (token based)
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
IID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat > /var/www/html/index.html <<HTML
<html><body style="font-family:sans-serif">
<h1>3-Tier AWS App (${environment})</h1>
<p>Served by instance <b>$IID</b> in <b>$AZ</b></p>
<p>Database endpoint (private subnet): <code>${db_endpoint}</code></p>
</body></html>
HTML

systemctl enable --now httpd
