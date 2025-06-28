#!/bin/bash

# Script to setup kubectl access on bastion host
# This script should be run on the bastion host after the cluster is deployed

echo "Setting up kubectl access on bastion host..."

# Get the master node IP from terraform output
MASTER_IP=$(terraform output -raw k3s_master_private_ip)

if [ -z "$MASTER_IP" ]; then
    echo "Error: Could not get master IP. Make sure terraform has been applied."
    exit 1
fi

echo "Master IP: $MASTER_IP"

# Create .kube directory
mkdir -p ~/.kube

# Get kubeconfig from master node
echo "Retrieving kubeconfig from master node..."
ssh -i task2-key.pem -o StrictHostKeyChecking=no ec2-user@$MASTER_IP "cat /home/ec2-user/.kube/config" > ~/.kube/config

# Update the server IP in kubeconfig
sed -i "s/127.0.0.1/$MASTER_IP/g" ~/.kube/config

echo "Kubectl configuration completed!"
echo "Testing connection..."

# Test kubectl connection
kubectl get nodes

if [ $? -eq 0 ]; then
    echo "✅ Successfully connected to K3s cluster!"
    echo "You can now run kubectl commands from this bastion host."
else
    echo "❌ Failed to connect to K3s cluster. Please check the configuration."
fi