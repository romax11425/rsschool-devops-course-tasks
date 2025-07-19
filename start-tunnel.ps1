# Скрипт для запуска minikube tunnel
# Запускать в отдельном окне PowerShell с правами администратора

Write-Host "Запускаем minikube tunnel для доступа к ingress ресурсам..." -ForegroundColor Green
Write-Host "Этот процесс должен оставаться запущенным, пока вы работаете с кластером" -ForegroundColor Yellow
Write-Host "Для остановки нажмите Ctrl+C" -ForegroundColor Yellow
Write-Host ""

# Запуск minikube tunnel
minikube tunnel