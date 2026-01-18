#!/usr/bin/env bash
set -euo pipefail

if ! command -v kubeshark >/dev/null 2>&1; then
  echo "Missing dependency: kubeshark" >&2
  exit 1
fi

kubeshark tap -n agents
