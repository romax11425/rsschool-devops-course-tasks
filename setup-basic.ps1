# Basic setup script for Task 6
# Run as administrator in PowerShell

# Stop existing minikube cluster
Write-Host "Stopping existing minikube cluster..." -ForegroundColor Yellow
minikube delete

# Start minikube with Docker driver
Write-Host "Starting new minikube cluster..." -ForegroundColor Green
minikube start --driver=docker --memory=4096 --cpus=2 --disk-size=20g

# Check minikube status
minikube status

# Enable required addons
Write-Host "Enabling required addons..." -ForegroundColor Green
minikube addons enable storage-provisioner
minikube addons enable default-storageclass

# Install Jenkins directly with kubectl
Write-Host "Installing Jenkins..." -ForegroundColor Green
kubectl apply -f basic-jenkins.yaml

# Wait for Jenkins to start
Write-Host "Waiting for Jenkins to start (this may take a few minutes)..." -ForegroundColor Yellow
kubectl wait --namespace jenkins --for=condition=available deployment/jenkins --timeout=300s

# Get URL for Jenkins access
$MINIKUBE_IP = minikube ip
Write-Host "Jenkins will be available at: http://$MINIKUBE_IP`:30080" -ForegroundColor Green
Write-Host "Username: admin" -ForegroundColor Green

# Instructions for getting password
Write-Host "To get the admin password, run:" -ForegroundColor Yellow
Write-Host "kubectl exec -it -n jenkins `$(kubectl get pods -n jenkins -l app=jenkins -o jsonpath='{.items[0].metadata.name}') -- cat /var/jenkins_home/secrets/initialAdminPassword" -ForegroundColor Cyan

Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "Wait a few minutes for Jenkins to fully start." -ForegroundColor Yellow