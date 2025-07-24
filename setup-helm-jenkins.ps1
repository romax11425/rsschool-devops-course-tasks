# Script for setting up Jenkins using Helm
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

# Create namespace for Jenkins
Write-Host "Creating namespace for Jenkins..." -ForegroundColor Green
kubectl create namespace jenkins

# Add Jenkins Helm repository
Write-Host "Adding Jenkins Helm repository..." -ForegroundColor Green
helm repo add jenkins https://charts.jenkins.io
helm repo update

# Wait for webhook admission controller to be ready
Write-Host "Waiting for system to stabilize before installing Jenkins..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Install Jenkins using Helm
Write-Host "Installing Jenkins using Helm..." -ForegroundColor Green
helm install jenkins jenkins/jenkins --namespace jenkins --values jenkins-k8s-values.yaml --set controller.ingress.enabled=false

# Wait for Jenkins pod to be created
Write-Host "Waiting for Jenkins pod to be created..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Check pod status
Write-Host "Checking Jenkins pod status..." -ForegroundColor Yellow
$POD_NAME = kubectl get pods -n jenkins -o name | Select-String -Pattern "jenkins"
if ($POD_NAME) {
    Write-Host "Jenkins pod found: $POD_NAME" -ForegroundColor Green
    
    # Wait for pod to be ready
    Write-Host "Waiting for Jenkins to start (this may take a few minutes)..." -ForegroundColor Yellow
    try {
        kubectl wait --namespace jenkins --for=condition=ready pod $POD_NAME --timeout=300s
    } catch {
        Write-Host "Timeout waiting for Jenkins pod to be ready. Continuing anyway..." -ForegroundColor Yellow
    }
    
    # Get container name
    $CONTAINER_NAME = kubectl get pod $POD_NAME -n jenkins -o jsonpath='{.spec.containers[0].name}'
    Write-Host "Container name: $CONTAINER_NAME" -ForegroundColor Green
    
    # Get Jenkins admin password
    Write-Host "Getting Jenkins admin password..." -ForegroundColor Green
    try {
        # Try first location
        $JENKINS_PASSWORD = kubectl exec -n jenkins $POD_NAME -c $CONTAINER_NAME -- cat /run/secrets/additional/chart-admin-password 2>$null
        if (-not $JENKINS_PASSWORD) {
            # Try second location
            $JENKINS_PASSWORD = kubectl exec -n jenkins $POD_NAME -c $CONTAINER_NAME -- cat /var/jenkins_home/secrets/initialAdminPassword 2>$null
        }
        
        if ($JENKINS_PASSWORD) {
            Write-Host "Jenkins admin password: $JENKINS_PASSWORD" -ForegroundColor Green
        } else {
            Write-Host "Could not get password, check pod logs for issues" -ForegroundColor Yellow
            Write-Host "Default password might be 'admin'" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error getting password: $_" -ForegroundColor Red
        Write-Host "Try these commands manually:" -ForegroundColor Yellow
        Write-Host "kubectl exec -n jenkins $POD_NAME -c $CONTAINER_NAME -- cat /run/secrets/additional/chart-admin-password" -ForegroundColor Cyan
        Write-Host "kubectl exec -n jenkins $POD_NAME -c $CONTAINER_NAME -- cat /var/jenkins_home/secrets/initialAdminPassword" -ForegroundColor Cyan
        Write-Host "Default password might be 'admin'" -ForegroundColor Yellow
    }
} else {
    Write-Host "Jenkins pod not found. Check deployment status with: kubectl get pods -n jenkins" -ForegroundColor Red
}

# Get URL for Jenkins access
$MINIKUBE_IP = minikube ip
try {
    $NODE_PORT = kubectl get --namespace jenkins -o jsonpath="{.spec.ports[0].nodePort}" services jenkins
    if ($NODE_PORT) {
        Write-Host "Jenkins will be available at: http://$MINIKUBE_IP`:$NODE_PORT" -ForegroundColor Green
    } else {
        Write-Host "Jenkins will be available at: http://$MINIKUBE_IP:30080" -ForegroundColor Green
    }
} catch {
    Write-Host "Could not get NodePort. Try checking service with: kubectl get svc -n jenkins" -ForegroundColor Yellow
    Write-Host "Jenkins will be available at: http://$MINIKUBE_IP:30080" -ForegroundColor Green
}
Write-Host "Username: admin" -ForegroundColor Green
Write-Host "Password: $JENKINS_PASSWORD" -ForegroundColor Green

Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "Wait a few minutes for Jenkins to fully start." -ForegroundColor Yellow