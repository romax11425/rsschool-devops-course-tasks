# Script to get Jenkins admin password
# Run as administrator in PowerShell

# Get pod name
$POD_NAME = (kubectl get pods -n jenkins -o name | Select-String -Pattern "jenkins").ToString().Trim()
Write-Host "Jenkins pod: $POD_NAME" -ForegroundColor Green

# Try to get password directly
Write-Host "Trying to get password..." -ForegroundColor Yellow

# Try with jenkins container
try {
    Write-Host "Trying container: jenkins" -ForegroundColor Yellow
    
    # Try first location
    Write-Host "Trying /run/secrets/additional/chart-admin-password..." -ForegroundColor Yellow
    $PASSWORD = kubectl exec -n jenkins $POD_NAME -c jenkins -- cat /run/secrets/additional/chart-admin-password 2>$null
    
    # Try second location if first failed
    if (-not $PASSWORD) {
        Write-Host "Trying /var/jenkins_home/secrets/initialAdminPassword..." -ForegroundColor Yellow
        $PASSWORD = kubectl exec -n jenkins $POD_NAME -c jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword 2>$null
    }
} catch {
    Write-Host "Error with jenkins container: $_" -ForegroundColor Red
}

# If still no password, try with jenkins-controller container
if (-not $PASSWORD) {
    try {
        Write-Host "Trying container: jenkins-controller" -ForegroundColor Yellow
        
        # Try first location
        Write-Host "Trying /run/secrets/additional/chart-admin-password..." -ForegroundColor Yellow
        $PASSWORD = kubectl exec -n jenkins $POD_NAME -c jenkins-controller -- cat /run/secrets/additional/chart-admin-password 2>$null
        
        # Try second location if first failed
        if (-not $PASSWORD) {
            Write-Host "Trying /var/jenkins_home/secrets/initialAdminPassword..." -ForegroundColor Yellow
            $PASSWORD = kubectl exec -n jenkins $POD_NAME -c jenkins-controller -- cat /var/jenkins_home/secrets/initialAdminPassword 2>$null
        }
    } catch {
        Write-Host "Error with jenkins-controller container: $_" -ForegroundColor Red
    }
}

# Display password or default credentials
if ($PASSWORD) {
    Write-Host "Found password!" -ForegroundColor Green
    Write-Host "Password: $PASSWORD" -ForegroundColor Green
} else {
    Write-Host "Could not find password automatically." -ForegroundColor Red
    Write-Host "Try accessing Jenkins with default credentials:" -ForegroundColor Yellow
    Write-Host "Username: admin" -ForegroundColor Green
    Write-Host "Password: admin" -ForegroundColor Green
}

# Get URL for Jenkins access
$MINIKUBE_IP = minikube ip
$NODE_PORT = kubectl get --namespace jenkins -o jsonpath="{.spec.ports[0].nodePort}" services jenkins
Write-Host "Jenkins URL: http://$MINIKUBE_IP`:$NODE_PORT" -ForegroundColor Green