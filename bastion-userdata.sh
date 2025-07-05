#!/bin/bash

# Update system
dnf update -y

# Install packages
dnf install -y fail2ban git kubectl

# Configure fail2ban
cat > /etc/fail2ban/jail.local <<'EOT'
[sshd]
enabled = true
bantime = 3600
maxretry = 3
findtime = 600
EOT

systemctl enable fail2ban
systemctl start fail2ban

# Harden SSH
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# Setup SSH key for ec2-user
cat > /home/ec2-user/.ssh/id_rsa <<'EOF'
${ssh_key}
EOF
chmod 600 /home/ec2-user/.ssh/id_rsa
chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa

# Setup kubeconfig for ec2-user
mkdir -p /home/ec2-user/.kube
ssh -i /home/ec2-user/.ssh/id_rsa -o StrictHostKeyChecking=no ec2-user@${master_ip} "sudo cat /etc/rancher/k3s/k3s.yaml" > /home/ec2-user/.kube/config
sed -i 's/127.0.0.1:6443/${master_ip}:6443/g' /home/ec2-user/.kube/config
chmod 600 /home/ec2-user/.kube/config
chown ec2-user:ec2-user /home/ec2-user/.kube/config