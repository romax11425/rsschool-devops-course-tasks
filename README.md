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

# Connect to bastion
ssh -i task2-key.pem ec2-user@$(terraform output -raw bastion_public_ip)

# Setup kubectl on bastion
MASTER_IP=$(terraform output -raw k3s_master_private_ip)
mkdir -p ~/.kube
ssh -i task2-key.pem ec2-user@$MASTER_IP "cat /home/ec2-user/.kube/config" > ~/.kube/config
sed -i "s/127.0.0.1/$MASTER_IP/g" ~/.kube/config

# Verify cluster
kubectl get nodes

# Deploy test workload
kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml
kubectl get all --all-namespaces
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

### Scripts
- `scripts/k3s-master.sh` - K3s server installation script
- `scripts/k3s-worker.sh` - K3s agent installation script
- `scripts/setup-kubectl-bastion.sh` - Configure kubectl on bastion
- `scripts/setup-local-kubectl.sh` - Configure local kubectl access
- `scripts/validate-cluster.sh` - Cluster validation script

### Other Files
- `.github/workflows/terraform_execution.yml` - GitHub Actions workflow
- `.gitignore` - Git ignore rules
- `task2-key.pem` - Generated SSH private key

## Local Access

```bash
# Setup local kubectl access
./scripts/setup-local-kubectl.sh
./start-tunnel.sh &
export KUBECONFIG=~/.kube/config-k3s
kubectl get nodes
```

## Requirements

- Terraform = 1.12.2
- AWS CLI configured
- SSH client

## Cleanup

```bash
terraform destroy
```