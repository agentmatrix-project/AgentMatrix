#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-agent-matrix}"
KIND_CONFIG="${KIND_CONFIG:-configs/kind-config.yaml}"
CILIUM_VALUES="${CILIUM_VALUES:-configs/cilium-values.yaml}"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing dependency: $1" >&2
    exit 1
  fi
}

require_cmd kind
require_cmd kubectl
require_cmd helm

if ! kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  kind create cluster --name "${CLUSTER_NAME}" --config "${KIND_CONFIG}"
fi

helm repo add cilium https://helm.cilium.io >/dev/null
helm repo update >/dev/null

helm upgrade --install cilium cilium/cilium \
  --namespace kube-system \
  --create-namespace \
  --values "${CILIUM_VALUES}"

kubectl -n kube-system rollout status daemonset/cilium --timeout=5m
kubectl -n kube-system rollout status deployment/cilium-operator --timeout=5m

kubectl apply -f deploy/

echo "Cluster ready. Next: run 'scripts/run-kubeshark.sh' to capture payloads."
