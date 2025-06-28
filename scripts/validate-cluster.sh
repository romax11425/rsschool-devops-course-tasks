#!/bin/bash

# Script to validate K3s cluster deployment
# Run this script from the bastion host after setting up kubectl

echo "🔍 Validating K3s Cluster Deployment..."
echo "=================================="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check cluster connectivity
echo "1. Testing cluster connectivity..."
if kubectl cluster-info &> /dev/null; then
    echo "✅ Cluster is accessible"
else
    echo "❌ Cannot connect to cluster"
    exit 1
fi

# Check nodes
echo ""
echo "2. Checking cluster nodes..."
kubectl get nodes
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
if [ "$NODE_COUNT" -eq 2 ]; then
    echo "✅ Expected 2 nodes found"
else
    echo "❌ Expected 2 nodes, found $NODE_COUNT"
fi

# Check node status
echo ""
echo "3. Checking node readiness..."
NOT_READY=$(kubectl get nodes --no-headers | grep -v Ready | wc -l)
if [ "$NOT_READY" -eq 0 ]; then
    echo "✅ All nodes are Ready"
else
    echo "❌ Some nodes are not Ready"
fi

# Deploy test workload
echo ""
echo "4. Deploying test workload..."
kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml

# Wait for pod to be ready
echo "Waiting for pod to be ready..."
kubectl wait --for=condition=Ready pod/nginx --timeout=60s

if [ $? -eq 0 ]; then
    echo "✅ Test workload deployed successfully"
else
    echo "❌ Test workload failed to deploy"
fi

# Show all resources
echo ""
echo "5. Cluster resources overview..."
kubectl get all --all-namespaces

echo ""
echo "🎉 Cluster validation completed!"
echo "=================================="