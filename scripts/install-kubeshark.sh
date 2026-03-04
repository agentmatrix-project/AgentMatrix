#!/usr/bin/env bash
set -euo pipefail

KUBESHARK_NAMESPACE="${KUBESHARK_NAMESPACE:-kubeshark}"
KUBESHARK_RELEASE="${KUBESHARK_RELEASE:-kubeshark}"
KUBESHARK_CHART_VERSION="${KUBESHARK_CHART_VERSION:-52.4}"
KUBESHARK_VALUES="${KUBESHARK_VALUES:-configs/kubeshark-values.yaml}"

helm repo add kubeshark https://helm.kubeshark.com --force-update >/dev/null
helm repo update >/dev/null

helm upgrade --install "${KUBESHARK_RELEASE}" kubeshark/kubeshark \
  -n "${KUBESHARK_NAMESPACE}" --create-namespace \
  --version "${KUBESHARK_CHART_VERSION}" \
  -f "${KUBESHARK_VALUES}"

# To uninstall run:
# helm uninstall "${KUBESHARK_RELEASE}" -n "${KUBESHARK_NAMESPACE}"
