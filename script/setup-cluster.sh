#!/bin/bash
# setup-cluster.sh
set -euo pipefail

# 🔥 Make script path-independent (VERY IMPORTANT)
cd "$(dirname "$0")/.."

CLUSTER_NAME="online-boutique-cluster"
AWS_REGION="${AWS_REGION:-us-east-1}"
AWS_ACCOUNT_ID="720035686687"
ARGOCD_NAMESPACE="argocd"
MONITORING_NAMESPACE="monitoring"

echo "==> [1/5] Configuring kubectl for EKS..."
aws eks update-kubeconfig \
  --name "$CLUSTER_NAME" \
  --region "$AWS_REGION"

echo "    Granting IAM root access to cluster..."
aws eks create-access-entry \
  --cluster-name "$CLUSTER_NAME" \
  --principal-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:root" \
  --region "$AWS_REGION" 2>/dev/null || echo "    Access entry already exists, skipping."

aws eks associate-access-policy \
  --cluster-name "$CLUSTER_NAME" \
  --principal-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:root" \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
  --access-scope type=cluster \
  --region "$AWS_REGION" 2>/dev/null || echo "    Access policy already associated, skipping."

echo "==> [2/5] Installing ArgoCD..."
kubectl create namespace "$ARGOCD_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

kubectl apply --server-side --force-conflicts -n "$ARGOCD_NAMESPACE" \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "    Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available deployment/argocd-server \
  -n "$ARGOCD_NAMESPACE" --timeout=120s

echo "==> [3/5] Applying ArgoCD app manifest..."
kubectl wait --for=condition=established crd/applications.argoproj.io --timeout=60s

# ✅ FIXED PATH
kubectl apply -f argocd/apps/online-boutique-dev.yaml

echo "==> [4/5] Installing Prometheus + Grafana via Helm..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace "$MONITORING_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace "$MONITORING_NAMESPACE" \
  --set grafana.adminPassword=admin \
  --wait

echo "==> [5/5] Applying alert rules and service monitor..."
kubectl apply -f monitoring/alertrules.yaml || echo "    alertrules not found, skipping"
kubectl apply -f monitoring/servicemonitor.yaml || echo "    servicemonitor not found, skipping"

echo ""
echo "✅ Done!"
echo ""
echo "ArgoCD admin password:"
kubectl -n "$ARGOCD_NAMESPACE" get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo ""
echo "To access ArgoCD UI:  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "To access Grafana UI: kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80"
