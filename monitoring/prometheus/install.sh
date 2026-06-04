#!/bin/bash
echo "Installing Prometheus + Grafana..."

helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

helm install kube-prometheus-stack \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  -f monitoring/prometheus/values.yaml \
  --wait

echo ""
echo "Done! Getting Grafana URL..."
kubectl get svc kube-prometheus-stack-grafana -n monitoring

echo ""
echo "Grafana Login:"
echo "  Username: admin"
echo "  Password: OnlineBoutique@2026"
