#!/bin/bash
# Description: Automated setup script for Jenkins on Amazon Linux 2023
# Usage: Pass this as EC2 User Data or execute directly via user script

set -e

echo "=== Starting Jenkins Installation ==="

# 1. Update package manager
dnf update -y

# 2. Install OpenJDK 21 (Required by current Jenkins versions >= 2.440)
echo "=== Installing Java 21 ==="
dnf install -y java-21-amazon-corretto-devel

# Set Java 21 as default system java
alternatives --set java /usr/lib/jvm/java-21-amazon-corretto.x86_64/bin/java

# 3. Add Jenkins repository and GPG keys
echo "=== Adding Jenkins Repository ==="
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# 4. Install Jenkins
echo "=== Installing Jenkins Package ==="
dnf install -y jenkins

# 5. Configure systemd override to ensure proper JAVA_HOME and binary paths
echo "=== Configuring Systemd Override ==="
mkdir -p /etc/systemd/system/jenkins.service.d
cat <<'EOF' > /etc/systemd/system/jenkins.service.d/override.conf
[Service]
Environment="JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto.x86_64"
ExecStart=
ExecStart=/usr/bin/java -Djava.awt.headless=true -jar /usr/share/java/jenkins.war --webroot=/var/cache/jenkins/war --httpPort=8080
EOF

# 6. Set system-wide environment variables
echo "JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto.x86_64" >> /etc/environment

# 7. Enable and Start Jenkins Service
echo "=== Enabling and Starting Jenkins Service ==="
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

# 8. Output Initial Admin Password location
echo "=== Jenkins Installation Complete ==="
echo "Jenkins is running on port 8080."
echo "Initial Admin Password can be retrieved using:"
echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
