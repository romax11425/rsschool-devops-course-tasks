# RS School DevOps Course Tasks

This repository contains infrastructure and deployment configurations for multiple DevOps tasks including AWS K3s cluster deployment and Jenkins automation with Helm.

## Project Overview

### Task 2-3: K3s Kubernetes Cluster on AWS
Terraform infrastructure for deploying a K3s Kubernetes cluster on AWS with bastion host access.

### Task 4: Jenkins Deployment with Helm on Minikube
Jenkins deployment on Kubernetes using Helm charts in a local minikube environment with JCasC configuration and CI/CD pipeline setup.

## Project Structure

```
rsschool-devops-course-tasks/
├── .github/workflows/
│   ├── jenkins-deployment.yml     # GitHub Actions pipeline for Jenkins on AWS EKS
│   └── terraform_execution.yml    # Terraform automation for AWS infrastructure
├── helm-charts/jenkins/
│   ├── Chart.yaml                 # Helm chart metadata
│   └── values.yaml                # Jenkins configuration with JCasC
├── k8s-manifests/
│   └── jenkins-pvc.yaml          # Persistent Volume Claim for Jenkins
├── .terraform/                    # Terraform state files
├── Makefile                       # Automation commands for Task 4
├── README.md                     # This documentation
├── *.tf files                    # Terraform infrastructure files
└── *-userdata.sh                 # EC2 user data scripts
```

---

## Task 2-3: K3s Kubernetes Cluster on AWS

### Architecture

- **VPC**: Custom VPC with public/private subnets across 2 availability zones
- **Bastion Host**: EC2 instance in public subnet for secure access
- **K3s Master**: EC2 instance in private subnet running K3s server
- **K3s Worker**: EC2 instance in private subnet running K3s agent

### Quick Start

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

---

## Task 4: Jenkins Deployment with Helm on Minikube

### Prerequisites
- **VirtualBox** installed and running
- **minikube** v1.36.0 or later
- **Helm** 3.x installed
- **kubectl** configured
- **Windows PowerShell** or equivalent terminal

### Implementation Steps

#### 1. Environment Setup
```powershell
# Delete existing minikube cluster (if any)
minikube delete

# Start minikube with adequate resources
minikube start --driver=virtualbox --memory=4096 --cpus=2 --disk-size=20g

# Enable storage addons
minikube addons enable default-storageclass
minikube addons enable storage-provisioner

# Verify cluster
minikube status
kubectl get nodes
```

#### 2. Helm Installation and Verification
```powershell
# Verify Helm installation
helm version

# Test Helm with Nginx chart
helm install test-nginx oci://registry-1.docker.io/bitnamicharts/nginx
helm uninstall test-nginx
```

#### 3. Persistent Storage Setup
```powershell
# Apply PVC manifest
kubectl apply -f k8s-manifests/jenkins-pvc.yaml

# Verify storage classes and PVC
kubectl get storageclass
kubectl get pvc -n jenkins
kubectl get pv
```

#### 4. Jenkins Deployment
```powershell
# Add Jenkins Helm repository
helm repo add jenkins https://charts.jenkins.io
helm repo update

# Create Jenkins namespace
kubectl create namespace jenkins

# Deploy Jenkins with custom configuration
helm install jenkins jenkins/jenkins --namespace jenkins --values helm-charts/jenkins/values.yaml --wait

# Alternative: Simple installation without JCasC
helm install jenkins jenkins/jenkins --namespace jenkins \
  --set controller.serviceType=NodePort \
  --set controller.nodePort=30080 \
  --set controller.admin.password=admin123 \
  --set persistence.enabled=false
```

#### 5. Access Jenkins
```powershell
# Get minikube IP
minikube ip

# Access Jenkins web interface
# URL: http://<minikube-ip>:30080
# Username: admin
# Password: admin123

# Alternative: Port forwarding
kubectl port-forward -n jenkins svc/jenkins 8080:8080
# Then access: http://localhost:8080
```

#### 6. Create Hello World Job
**Manual Creation (Recommended):**
1. Open Jenkins web interface
2. Click "New Item"
3. Enter name: `hello-world-job`
4. Select "Freestyle project"
5. In Build Steps → Add build step → Execute shell
6. Command: `echo "Hello world from Jenkins on minikube!"`
7. Save and run the job
8. Check Console Output for verification

### Key Configuration Files

#### helm-charts/jenkins/values.yaml
Contains complete Jenkins configuration including:
- Service type and port configuration
- Admin user credentials
- Resource limits and requests
- JCasC configuration with Hello World job
- Required plugins installation
- Persistent storage settings

#### .github/workflows/jenkins-deployment.yml
GitHub Actions pipeline for automated deployment featuring:
- AWS credentials configuration
- EKS cluster connection
- Helm and kubectl setup
- Jenkins deployment automation

#### k8s-manifests/jenkins-pvc.yaml
Persistent Volume Claim specification:
- 5Gi storage allocation
- ReadWriteOnce access mode
- Standard storage class

### Task 4 Architecture Summary

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Minikube      │    │   Jenkins        │    │   Persistent    │
│   (VirtualBox)  │───▶│   Namespace      │───▶│   Volume        │
│   + Storage     │    │   + NodePort     │    │   (5Gi)         │
└─────────────────┘    └──────────────────┘    └─────────────────┘
        │                       │
        ▼                       ▼
┌─────────────────┐    ┌──────────────────┐
│   GitHub        │    │   Hello World    │
│   Actions       │    │   Job            │
│   Pipeline      │    │   (Manual)       │
└─────────────────┘    └──────────────────┘
```

---

## Common Operations

### Local Access to AWS K3s Cluster

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

### Troubleshooting

#### AWS K3s Cluster Issues
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

#### Jenkins on Minikube Issues
```powershell
# Check init container logs
kubectl logs jenkins-0 -n jenkins -c init
kubectl describe pod jenkins-0 -n jenkins

# Restart minikube
minikube stop
minikube start --driver=virtualbox --memory=4096 --cpus=2

# Verify storage addons
minikube addons list | findstr storage

# Check PVC status
kubectl get pvc -n jenkins
kubectl describe pvc jenkins-pvc -n jenkins
```

## Requirements

### Task 2-3 Requirements
- Terraform = 1.12.2
- AWS CLI configured
- SSH client
- kubectl (for local access)

### Task 4 Requirements
- VirtualBox
- minikube v1.36.0+
- Helm 3.x
- kubectl
- PowerShell or equivalent

## Cost Optimization

- Uses AWS Free Tier eligible instances where possible
- Single NAT Gateway to reduce costs
- Optimized K3s configuration for minimal resource usage
- Local minikube deployment for development/testing

## Submission Files

### Task 2-3 Files
- All *.tf files
- User data scripts
- .github/workflows/terraform_execution.yml
- Generated SSH key (task2-key.pem)

### Task 4 Files
- helm-charts/jenkins/Chart.yaml
- helm-charts/jenkins/values.yaml
- .github/workflows/jenkins-deployment.yml
- k8s-manifests/jenkins-pvc.yaml
- Makefile (updated for Task 4)

### Screenshots Required (Task 4)
1. Jenkins Console Output showing "Hello world" message
2. kubectl get all --all-namespaces output
3. Jenkins web interface with created job

## Cleanup

```bash
# Clean up AWS infrastructure
terraform destroy

# Clean up minikube
helm uninstall jenkins -n jenkins
kubectl delete namespace jenkins
minikube stop
minikube delete
```

## Project Context
- **Multi-task repository**: Contains infrastructure from previous tasks (Terraform, AWS)
- **Task coexistence**: Local minikube deployment independent of AWS resources
- **Comprehensive solution**: Covers both cloud infrastructure and local development workflows
- **Production ready**: All configurations optimized for real-world deployment scenarios