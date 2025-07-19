# Task 6: Application Deployment via Jenkins Pipeline

## Overview
This project demonstrates a complete CI/CD pipeline using Jenkins to deploy a Flask application to a Kubernetes cluster (minikube). The pipeline includes build, test, security scanning, Docker image creation, and deployment stages.

## Prerequisites
- minikube running on Docker
- Jenkins installed with necessary plugins
- SonarQube server configured
- Docker Hub account
- kubectl configured for minikube
- Helm installed

## Setup Instructions

### 1. Minikube Setup
```bash
# Start minikube with adequate resources
minikube start --driver=docker --memory=4096 --cpus=2 --disk-size=20g

# Verify minikube is running
minikube status
```

### 2. Jenkins Configuration

#### Required Jenkins Plugins
- Docker Pipeline
- Kubernetes CLI
- SonarQube Scanner
- Slack Notification
- Pipeline Utility Steps

#### Jenkins Credentials Setup
1. Add Docker Hub credentials:
   - Kind: Username with password
   - ID: docker-hub-credentials
   - Username: Your Docker Hub username
   - Password: Your Docker Hub password

2. Add SonarQube credentials:
   - Kind: Secret text
   - ID: sonarqube-token
   - Secret: Your SonarQube token

3. Add Slack credentials:
   - Kind: Secret text
   - ID: slack-token
   - Secret: Your Slack token

#### Configure Jenkins Pipeline
1. Create a new Pipeline job in Jenkins
2. Configure SCM to point to your Git repository
3. Set the Script Path to "Jenkinsfile"
4. Configure webhook in your Git repository to trigger the pipeline on push events

### 3. SonarQube Setup
1. Install SonarQube server (or use SonarCloud)
2. Create a new project with key "flask-app"
3. Generate an authentication token
4. Configure Jenkins SonarQube plugin with server details

### 4. Application Structure
```
app/
├── main.py              # Flask application
├── requirements.txt     # Python dependencies
├── test_main.py         # Unit tests
└── Dockerfile           # Docker image definition

helm-charts/flask-app/
├── Chart.yaml           # Helm chart metadata
├── values.yaml          # Configuration values
└── templates/
    ├── deployment.yaml  # Kubernetes deployment
    └── service.yaml     # Kubernetes service
```

## Pipeline Workflow

1. **Checkout**: Retrieves code from Git repository
2. **Build**: Installs Python dependencies
3. **Unit Tests**: Runs pytest with coverage reporting
4. **SonarQube Analysis**: Performs code quality and security scanning
5. **Build Docker Image**: Creates Docker image from application code
6. **Push Docker Image**: Uploads image to Docker Hub registry
7. **Deploy to Kubernetes**: Updates Helm chart values and deploys to minikube
8. **Verify Deployment**: Tests that the application is accessible and working

## Notifications

The pipeline is configured to send Slack notifications on:
- Successful pipeline completion
- Pipeline failures

## Troubleshooting

### Common Issues
1. **Docker image push fails**: Check Docker Hub credentials in Jenkins
2. **SonarQube analysis fails**: Verify SonarQube server is accessible and token is valid
3. **Deployment to Kubernetes fails**: Ensure minikube is running and kubectl is configured correctly
4. **Verification fails**: Check if the application is accessible on the expected port

### Debug Commands
```bash
# Check minikube status
minikube status

# View Kubernetes resources
kubectl get all

# Check pod logs
kubectl logs -l app=flask-app

# Verify Helm release
helm list
```

## Manual Testing

After successful deployment, you can access the application:
```bash
# Get minikube IP
minikube ip

# Access in browser
# URL: http://<minikube-ip>:30081
```

## Security Considerations
- SonarQube scans for security vulnerabilities
- Docker image is built with minimal dependencies
- Kubernetes deployment follows best practices
- Credentials are stored securely in Jenkins

## Future Improvements
- Add integration tests
- Implement canary deployments
- Add monitoring and alerting
- Configure horizontal pod autoscaling


# Task 5: WebApp Helm Chart Deployment

## Overview
This project demonstrates deployment of a simple web application using Helm charts on Kubernetes (minikube).

## Prerequisites
- minikube running
- Helm 3.x installed
- kubectl configured

## Application Structure

```
helm-charts/webapp/
├── Chart.yaml          # Helm chart metadata
├── values.yaml         # Configuration values
└── templates/
    ├── deployment.yaml # Kubernetes deployment
    └── service.yaml    # Kubernetes service
```

## Deployment Steps

### 1. Deploy the Application
```bash
# Install webapp using Helm
helm install webapp helm-charts/webapp

# Verify deployment
kubectl get pods
kubectl get svc
```

### 2. Access the Application
```bash
# Get minikube IP
minikube ip

# Access application in browser
# URL: http://<minikube-ip>:30082
```

### 3. Verify Application
```bash
# Check application status
helm status webapp

# Test HTTP response
curl http://$(minikube ip):30082
```

## Configuration

### values.yaml
- **Image**: nginx:latest
- **Replicas**: 1
- **Service Type**: NodePort
- **Port**: 30082
- **Resources**: 100m CPU, 128Mi memory

### Chart.yaml
- **Name**: webapp
- **Version**: 0.1.0
- **App Version**: 1.0

## Management Commands

```bash
# List Helm releases
helm list

# Upgrade application
helm upgrade webapp helm-charts/webapp

# Uninstall application
helm uninstall webapp

# View application logs
kubectl logs -l app=webapp
```

## Troubleshooting

### Common Issues
1. **Pod not starting**: Check resource limits
2. **Service not accessible**: Verify NodePort configuration
3. **Image pull errors**: Check internet connectivity

### Debug Commands
```bash
# Describe pod
kubectl describe pod -l app=webapp

# Check events
kubectl get events --sort-by='.lastTimestamp'

# View pod logs
kubectl logs -l app=webapp
```

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Browser       │───▶│   NodePort       │───▶│   Nginx Pod     │
│   :30082        │    │   Service        │    │   :80           │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Files Created
- `helm-charts/webapp/Chart.yaml` - Helm chart metadata
- `helm-charts/webapp/values.yaml` - Application configuration
- `helm-charts/webapp/templates/deployment.yaml` - Kubernetes deployment
- `helm-charts/webapp/templates/service.yaml` - Kubernetes service
- `webapp-README.md` - This documentation

## Success Criteria
✅ Helm chart created  
✅ Application deployed  
✅ Web browser accessible  
✅ Artifacts stored in Git  
✅ Documentation provided  

## Next Steps
1. Deploy the application: `helm install webapp helm-charts/webapp`
2. Access via browser: `http://<minikube-ip>:30082`

# RS School DevOps Course Tasks

This repository contains infrastructure and deployment configurations for multiple DevOps tasks including AWS K3s cluster deployment, Jenkins automation with Helm, and CI/CD pipeline for application deployment.

## Project Overview

### Task 2-3: K3s Kubernetes Cluster on AWS
Terraform infrastructure for deploying a K3s Kubernetes cluster on AWS with bastion host access.

### Task 4: Jenkins Deployment with Helm on Minikube
Jenkins deployment on Kubernetes using Helm charts in a local minikube environment with JCasC configuration and CI/CD pipeline setup.

### Task 6: Application Deployment via Jenkins Pipeline
Complete CI/CD pipeline using Jenkins to deploy a Flask application to Kubernetes with build, test, security scanning, Docker image creation, and deployment stages.

## Project Structure

```
rsschool-devops-course-tasks/
├── .github/workflows/
│   ├── jenkins-deployment.yml     # GitHub Actions pipeline for Jenkins on AWS EKS
│   └── terraform_execution.yml    # Terraform automation for AWS infrastructure
├── app/
│   ├── main.py                    # Flask application
│   ├── test_main.py               # Unit tests
│   ├── requirements.txt           # Python dependencies
│   └── Dockerfile                 # Docker image definition
├── helm-charts/
│   ├── flask-app/                 # Helm chart for Flask application
│   │   ├── templates/
│   │   │   ├── deployment.yaml    # Kubernetes deployment
│   │   │   └── service.yaml       # Kubernetes service
│   │   ├── Chart.yaml             # Helm chart metadata
│   │   └── values.yaml            # Configuration values
│   ├── jenkins/
│   │   ├── Chart.yaml             # Helm chart metadata
│   │   └── values.yaml            # Jenkins configuration with JCasC
│   └── webapp/
│       ├── templates/
│       │   ├── deployment.yaml    # Kubernetes deployment
│       │   └── service.yaml       # Kubernetes service
│       ├── Chart.yaml             # Helm chart metadata
│       └── values.yaml            # Configuration values
├── k8s-manifests/
│   └── jenkins-pvc.yaml          # Persistent Volume Claim for Jenkins
├── .terraform/                    # Terraform state files
├── Jenkinsfile                    # Jenkins pipeline definition for Task 6
├── jenkins-k8s-values.yaml        # Jenkins Helm values for Task 6
├── Makefile                       # Automation commands for Task 4
├── README.md                      # This documentation
├── setup-environment.ps1          # PowerShell script for environment setup
├── sonar-project.properties       # SonarQube configuration
├── TASK6-README.md               # Task 6 specific documentation
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
- **Docker** installed and running
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
minikube start --driver=docker --memory=4096 --cpus=2 --disk-size=20g

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
│   (Docker)      │───▶│   Namespace      │───▶│   Volume        │
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
minikube start --driver=docker --memory=4096 --cpus=2

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
- Docker
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

---

## Task 6: Application Deployment via Jenkins Pipeline

### Quick Start

```powershell
# Run setup script to configure environment
.\setup-environment.ps1

# Access Jenkins UI at http://<minikube-ip>:30080
# Access SonarQube UI at http://<minikube-ip>:30082
```

> **Note:** This setup uses Docker as the minikube driver instead of VirtualBox

### Pipeline Features
- **Automated Builds**: Compiles and builds the application
- **Unit Testing**: Runs tests and generates coverage reports
- **Security Scanning**: Integrates with SonarQube for code quality and security analysis
- **Docker Integration**: Builds and pushes Docker images to registry
- **Kubernetes Deployment**: Deploys application to Kubernetes using Helm
- **Notifications**: Sends Slack notifications on pipeline events

### Key Files
- `Jenkinsfile`: Jenkins pipeline definition
- `app/`: Flask application source code
- `helm-charts/flask-app/`: Helm chart for application deployment
- `sonar-project.properties`: SonarQube configuration
- `jenkins-k8s-values.yaml`: Jenkins Helm values
- `setup-environment.ps1`: Environment setup script
- `TASK6-README.md`: Detailed documentation

### Accessing the Application

After successful deployment, the Flask application is accessible at:
```
http://<minikube-ip>:30081
```

### Screenshots

![Jenkins Pipeline](./screenshots/jenkins-pipeline.png)
![Application Running](./screenshots/flask-app-running.png)
![SonarQube Analysis](./screenshots/sonarqube-analysis.png)

## Project Context
- **Multi-task repository**: Contains infrastructure from previous tasks (Terraform, AWS)
- **Task coexistence**: Local minikube deployment independent of AWS resources
- **Comprehensive solution**: Covers both cloud infrastructure and local development workflows
- **Production ready**: All configurations optimized for real-world deployment scenarios