#!/bin/bash

# Monitoring Stack Deployment Script
set -e

echo "🚀 Starting Kubernetes Monitoring Stack Deployment..."

# Add Helm repositories
echo "📦 Adding Helm repositories..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create monitoring namespace
echo "🏗️ Creating monitoring namespace..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Deploy secrets and configs
echo "🔐 Deploying secrets and configurations..."
kubectl apply -f monitoring/grafana/admin-secret.yaml
kubectl apply -f monitoring/grafana/dashboard-configmap.yaml
kubectl apply -f monitoring/alertmanager/alertmanager-config.yaml

# Deploy Prometheus Stack
echo "📊 Deploying Prometheus Stack..."
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values monitoring/helm-values/prometheus-values.yaml \
  --wait

# Deploy Grafana
echo "📈 Deploying Grafana..."
helm upgrade --install grafana bitnami/grafana \
  --namespace monitoring \
  --values monitoring/helm-values/grafana-values.yaml \
  --wait

# Apply alert rules
echo "🚨 Applying alert rules..."
kubectl apply -f monitoring/alertmanager/alert-rules.yaml

# Wait for deployments
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n monitoring

echo "✅ Monitoring stack deployed successfully!"
echo ""
echo "🔗 Access URLs:"
echo "Prometheus: kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
echo "Grafana: kubectl port-forward -n monitoring svc/grafana 3000:3000"
echo "Alertmanager: kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093"
echo ""
echo "📊 Grafana Login:"
echo "Username: admin"
echo "Password: admin123"