#!/bin/bash

# Get IPs from terraform
BASTION_IP=$(terraform output -raw bastion_public_ip)
MASTER_IP=$(terraform output -raw k3s_master_private_ip)

# Create local kubeconfig
mkdir -p ~/.kube
ssh -i task2-key.pem -o ProxyCommand="ssh -i task2-key.pem -W %h:%p ec2-user@$BASTION_IP" ec2-user@$MASTER_IP "cat ~/.kube/config" > ~/.kube/config-k3s

# Create tunnel script
cat > start-tunnel.sh << EOF
#!/bin/bash
ssh -i task2-key.pem -L 6443:$MASTER_IP:6443 ec2-user@$BASTION_IP -N
EOF
chmod +x start-tunnel.sh

# Update kubeconfig for local access
sed -i 's/https:\/\/127.0.0.1:6443/https:\/\/127.0.0.1:6443/' ~/.kube/config-k3s

echo "Setup complete!"
echo "1. Run: ./start-tunnel.sh (keep running)"
echo "2. In new terminal: export KUBECONFIG=~/.kube/config-k3s"
echo "3. Test: kubectl get nodes"