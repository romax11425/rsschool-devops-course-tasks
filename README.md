# K3s Kubernetes Cluster on AWS

This project deploys a K3s Kubernetes cluster on AWS using Terraform, consisting of a master node and a worker node in private subnets, accessible through a bastion host.

## 🚀 Quick Start

```bash
# Deploy infrastructure
terraform init && terraform apply -auto-approve

# Connect to bastion
ssh -i task2-key.pem ec2-user@$(terraform output -raw bastion_public_ip)

# Setup kubectl on bastion
MASTER_IP=$(terraform output -raw k3s_master_private_ip)
mkdir -p ~/.kube
ssh -i task2-key.pem ec2-user@$MASTER_IP "cat /home/ec2-user/.kube/config" > ~/.kube/config
sed -i "s/127.0.0.1/$MASTER_IP/g" ~/.kube/config

# Verify cluster (2 nodes Ready)
kubectl get nodes

# Deploy test workload
kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml
kubectl get all --all-namespaces
```

## Architecture

- **VPC**: Custom VPC with public/private subnets across 2 AZs
- **Bastion Host**: EC2 in public subnet for secure access
- **K3s Master**: EC2 in private subnet running K3s server
- **K3s Worker**: EC2 in private subnet running K3s agent
- **Security**: Hardened with fail2ban, SSH keys only

## Infrastructure Components

- **Networking**: VPC (10.0.0.0/16), IGW, NAT Gateway, route tables, NACLs
- **Compute**: 3x t2.micro instances (Free Tier eligible)
- **Storage**: S3 bucket with versioning for Terraform state
- **Security**: Security groups, SSH key authentication
- **IAM**: GitHub Actions OIDC integration

## File Structure

- `k3s_cluster.tf` - K3s master and worker nodes
- `bastion.tf` - Bastion host configuration
- `keys.tf` - SSH key pair generation
- `vpc.tf` - VPC and subnets
- `security.tf` - Security groups
- `outputs.tf` - Connection information
- `scripts/` - Automation scripts

## Local Access Setup

```bash
# Setup local kubectl access
./scripts/setup-local-kubectl.sh
./start-tunnel.sh &
export KUBECONFIG=~/.kube/config-k3s
kubectl get nodes
```

## Troubleshooting

```bash
# Check K3s services
sudo systemctl status k3s        # on master
sudo systemctl status k3s-agent  # on worker

# View logs
sudo journalctl -u k3s -f        # master logs
sudo journalctl -u k3s-agent -f  # worker logs
```

## Requirements

- Terraform >= 1.12.2
- AWS CLI configured
- SSH client
- kubectl (for local access)

## Cleanup

```bash
terraform destroy -auto-approve
```

## Security Features

- Private subnets for K3s nodes
- Bastion host with fail2ban protection
- SSH key-only authentication
- Restrictive security groups
- Network ACLs for additional security

## Cost Optimization

- t2.micro instances (AWS Free Tier)
- Single NAT Gateway
- Minimal resource allocation