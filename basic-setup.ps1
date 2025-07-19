# Базовый скрипт для настройки окружения для Task 6
# Запускать с правами администратора в PowerShell

# Остановка существующего minikube кластера
Write-Host "Останавливаем существующий minikube кластер..." -ForegroundColor Yellow
minikube delete

# Запуск minikube с Docker драйвером
Write-Host "Запускаем новый minikube кластер..." -ForegroundColor Green
minikube start --driver=docker --memory=4096 --cpus=2 --disk-size=20g

# Проверка статуса minikube
minikube status

# Включение необходимых аддонов
Write-Host "Включаем необходимые аддоны..." -ForegroundColor Green
minikube addons enable storage-provisioner
minikube addons enable default-storageclass

# Установка Jenkins напрямую через kubectl
Write-Host "Устанавливаем Jenkins..." -ForegroundColor Green
kubectl apply -f basic-jenkins.yaml

# Ожидание запуска Jenkins
Write-Host "Ожидаем запуска Jenkins (это может занять несколько минут)..." -ForegroundColor Yellow
kubectl wait --namespace jenkins --for=condition=available deployment/jenkins --timeout=300s

# Получение URL для доступа к Jenkins
$MINIKUBE_IP = minikube ip
Write-Host "Jenkins будет доступен по адресу: http://$MINIKUBE_IP`:30080" -ForegroundColor Green
Write-Host "Логин: admin" -ForegroundColor Green

# Инструкции по получению пароля
Write-Host "Для получения пароля администратора выполните:" -ForegroundColor Yellow
Write-Host "kubectl exec -it -n jenkins `$(kubectl get pods -n jenkins -l app=jenkins -o jsonpath='{.items[0].metadata.name}') -- cat /var/jenkins_home/secrets/initialAdminPassword" -ForegroundColor Cyan

Write-Host "Настройка окружения завершена!" -ForegroundColor Green
Write-Host "Подождите несколько минут, пока Jenkins полностью запустится." -ForegroundColor Yellow