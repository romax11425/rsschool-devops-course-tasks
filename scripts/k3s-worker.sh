#!/bin/bash

# Update system
dnf update -y

# Wait for master to be ready
sleep 90

# Install k3s agent (worker)
curl -sfL https://get.k3s.io | K3S_URL=https://${master_ip}:6443 K3S_TOKEN="${k3s_token}" sh -

# Wait for the agent to start
sleep 30

# Log installation completion
echo "K3s worker installation completed at $(date)" >> /var/log/k3s-install.log