# Script to reinstall Jenkins with simplified configuration
# Run as administrator in PowerShell

# Delete current Jenkins installation
Write-Host "Deleting current Jenkins installation..." -ForegroundColor Yellow
helm uninstall jenkins -n jenkins
kubectl delete namespace jenkins

# Wait for resources to be cleaned up
Write-Host "Waiting for resources to be cleaned up..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Create namespace for Jenkins
Write-Host "Creating namespace for Jenkins..." -ForegroundColor Green
kubectl create namespace jenkins

# Install Jenkins with simplified configuration
Write-Host "Installing Jenkins with simplified configuration..." -ForegroundColor Green
helm install jenkins jenkins/jenkins --namespace jenkins --values jenkins-k8s-values.yaml --set controller.ingress.enabled=false

# Wait for Jenkins pod to be created
Write-Host "Waiting for Jenkins pod to be created..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Check pod status
Write-Host "Checking Jenkins pod status..." -ForegroundColor Yellow
kubectl get pods -n jenkins

# Wait for pod to be ready
Write-Host "Waiting for Jenkins to start (this may take a few minutes)..." -ForegroundColor Yellow
kubectl wait --namespace jenkins --for=condition=ready pod -l app.kubernetes.io/component=jenkins-controller --timeout=300s

# Get Jenkins admin password
Write-Host "Getting Jenkins admin password..." -ForegroundColor Green
try {
    # Получаем имя пода
    $POD_NAME = kubectl get pods -n jenkins -o name | Select-String -Pattern "jenkins"
    
    # Получаем имя контейнера
    $CONTAINER_NAME = kubectl get pod $POD_NAME -n jenkins -o jsonpath='{.spec.containers[0].name}'
    Write-Host "Container name: $CONTAINER_NAME" -ForegroundColor Green
    
    # Пробуем получить пароль из разных мест
    $JENKINS_PASSWORD = kubectl exec -n jenkins $POD_NAME -c $CONTAINER_NAME -- cat /run/secrets/additional/chart-admin-password 2>$null
    
    if (-not $JENKINS_PASSWORD) {
        $JENKINS_PASSWORD = kubectl exec -n jenkins $POD_NAME -c $CONTAINER_NAME -- cat /var/jenkins_home/secrets/initialAdminPassword 2>$null
    }
    
    if ($JENKINS_PASSWORD) {
        Write-Host "Jenkins admin password: $JENKINS_PASSWORD" -ForegroundColor Green
    } else {
        Write-Host "Could not get password automatically. Try manually with:" -ForegroundColor Yellow
        Write-Host "kubectl exec -n jenkins $POD_NAME -c $CONTAINER_NAME -- cat /var/jenkins_home/secrets/initialAdminPassword" -ForegroundColor Cyan
    }
} catch {
    Write-Host "Error getting password: $_" -ForegroundColor Red
    Write-Host "Try getting the password manually after Jenkins fully starts" -ForegroundColor Yellow
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
if ($JENKINS_PASSWORD) {
    Write-Host "Password: $JENKINS_PASSWORD" -ForegroundColor Green
} else {
    Write-Host "Get password using the command shown above" -ForegroundColor Yellow
}

Write-Host "Setup complete!" -ForegroundColor Green