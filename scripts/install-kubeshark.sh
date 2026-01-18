#!/usr/bin/env bash
set -euo pipefail

helm install kubeshark kubeshark/kubeshark \
  -n kubeshark --create-namespace \
  --version 52.4
