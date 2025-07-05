# K3s Kubernetes Cluster on AWS

Terraform infrastructure for deploying a K3s Kubernetes cluster on AWS with bastion host access.

## Architecture

- **VPC**: Custom VPC with public/private subnets across 2 availability zones
- **Bastion Host**: EC2 instance in public subnet for secure access
- **K3s Master**: EC2 instance in private subnet running K3s server
- **K3s Worker**: EC2 instance in private subnet running K3s agent

## Quick Start

```bash
# Deploy infrastructure
terraform init
terraform apply

# Fix SSH key permissions (Windows)
icacls task2-key.pem /inheritance:r
icacls task2-key.pem /grant:r "%username%:R"

# Fix SSH key permissions (Linux/Mac)
chmod 400 task2-key.pem

# Connect to bastion (kubectl is auto-configured)
ssh -i task2-key.pem ec2-user@$(terraform output -raw bastion_public_ip)

# Verify cluster (2 nodes expected)
kubectl get nodes

# Deploy test workload
kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml

# Verify deployment
kubectl get all --all-namespaces
kubectl get pod nginx
```

## File Structure

### Terraform Files
- `main.tf` - Main configuration and providers
- `providers.tf` - AWS provider configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `backend.tf` - S3 backend configuration
- `vpc.tf` - VPC and subnets
- `routing.tf` - Route tables and gateways
- `security.tf` - Security groups
- `network_acls.tf` - Network ACLs
- `bastion.tf` - Bastion host configuration
- `k3s_cluster.tf` - K3s master and worker nodes
- `keys.tf` - SSH key pair generation
- `s3_bucket.tf` - S3 bucket for state
- `iam.tf` - IAM roles for GitHub Actions
- `data.tf` - Data sources

### User Data Scripts
- `bastion-userdata.sh` - Bastion host initialization and kubectl setup
- `k3s-master-userdata.sh` - K3s server installation with optimizations
- `k3s-worker-userdata.sh` - K3s agent installation script

### Other Files
- `.github/workflows/terraform_execution.yml` - GitHub Actions workflow
- `.gitignore` - Git ignore rules
- `task2-key.pem` - Generated SSH private key

## Local Access

```bash
# Get bastion and master IPs
BASTION_IP=$(terraform output -raw bastion_public_ip)
MASTER_IP=$(terraform output -raw k3s_master_private_ip)

# Create SSH tunnel (keep running)
ssh -i task2-key.pem -L 6443:$MASTER_IP:6443 ec2-user@$BASTION_IP -N &

# Get kubeconfig from bastion
ssh -i task2-key.pem ec2-user@$BASTION_IP "cat ~/.kube/config" > ~/.kube/config-k3s
sed -i "s/$MASTER_IP:6443/127.0.0.1:6443/g" ~/.kube/config-k3s

# Test local access
export KUBECONFIG=~/.kube/config-k3s
kubectl get nodes
```

## Infrastructure Details

### Instance Types
- **K3s Nodes**: t3.small (optimized for Kubernetes workloads)
- **Bastion Host**: t2.micro (sufficient for SSH gateway)

### Security Features
- Private subnets for K3s nodes
- Bastion host with fail2ban protection
- SSH key-only authentication
- Restrictive security groups
- Network ACLs for additional security

### K3s Optimizations
- Disabled unnecessary components (traefik, servicelb, metrics-server)
- Limited API server requests for better performance on small instances
- Automatic kubectl configuration on bastion host

## Troubleshooting

```bash
# Check K3s status on master node
sudo systemctl status k3s

# View K3s logs
sudo journalctl -u k3s -f

# If kubectl hangs, use system kubeconfig
sudo kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get nodes

# Check connectivity between nodes
ping <master-ip>
telnet <master-ip> 6443
```

## Requirements

- Terraform = 1.12.2
- AWS CLI configured
- SSH client
- kubectl (for local access)

## Cost Optimization

- Uses AWS Free Tier eligible instances where possible
- Single NAT Gateway to reduce costs
- Optimized K3s configuration for minimal resource usage

## Cleanup

```bash
terraform destroy
```