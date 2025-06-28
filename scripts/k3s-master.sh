#!/bin/bash

# Update system
dnf update -y

# Install k3s server with predefined token
curl -sfL https://get.k3s.io | K3S_TOKEN="${k3s_token}" sh -s - --write-kubeconfig-mode 644

# Wait for k3s to be ready
sleep 30

# Copy kubeconfig for ec2-user
mkdir -p /home/ec2-user/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/.kube/config
chown -R ec2-user:ec2-user /home/ec2-user/.kube

# Install kubectl for convenience
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Create a script to copy kubeconfig to bastion
cat > /home/ec2-user/setup-bastion-access.sh << 'EOL'
#!/bin/bash
# This script should be run from the bastion host to setup kubectl access
# Usage: ssh to master node and run: cat /home/ec2-user/.kube/config
# Then copy the content to bastion host ~/.kube/config and update server IP
EOL

chmod +x /home/ec2-user/setup-bastion-access.sh
chown ec2-user:ec2-user /home/ec2-user/setup-bastion-access.sh

# Log installation completion
echo "K3s master installation completed at $(date)" >> /var/log/k3s-install.log