#!/usr/bin/env bash
set -euo pipefail

# Configure port forwarding for kubershar.
# After that you should be able to access the panel in 0.0.0.0:8899

kubectl port-forward -n kubeshark service/kubeshark-front 8899:80
