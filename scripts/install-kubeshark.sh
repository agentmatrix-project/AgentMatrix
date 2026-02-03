#!/usr/bin/env bash
set -euo pipefail

helm install kubeshark kubeshark/kubeshark \
  -n kubeshark --create-namespace \
  --version 52.4 -f configs/kubeshark-values.yaml

# To uninstall run:
# helm uninstall kubeshark -n kubeshark
