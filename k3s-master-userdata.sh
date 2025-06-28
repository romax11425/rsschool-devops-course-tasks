#!/bin/bash

# Update system
dnf update -y

# Install k3s server with optimizations
curl -sfL https://get.k3s.io | K3S_TOKEN="${k3s_token}" sh -s - \
  --write-kubeconfig-mode 644 \
  --disable traefik \
  --disable servicelb \
  --disable metrics-server \
  --kube-apiserver-arg=--max-requests-inflight=100 \
  --kube-apiserver-arg=--max-mutating-requests-inflight=50

# Wait for k3s to be ready
sleep 30

# Copy kubeconfig for ec2-user
mkdir -p /home/ec2-user/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/.kube/config
chown -R ec2-user:ec2-user /home/ec2-user/.kube

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/