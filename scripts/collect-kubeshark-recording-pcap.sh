#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${KUBESHARK_NAMESPACE:-kubeshark}"
OUT_FILE=""
RECORDING_ID=""

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing dependency: $1" >&2
    exit 1
  fi
}

usage() {
  cat <<USAGE
Usage:
  scripts/collect-kubeshark-recording-pcap.sh <recording-id> [-o output.pcap] [-n namespace]

Arguments:
  <recording-id>    Kubeshark recording ID to collect.

Options:
  -o <file>         Output merged pcap file (default: recording-<recording-id>-merged.pcap)
  -n <namespace>    Kubeshark namespace (default: kubeshark or \$KUBESHARK_NAMESPACE)
  -h                Show help

Notes:
  - Requires kubectl access to Kubeshark worker pods.
  - Requires mergecap (from Wireshark/tshark).
USAGE
}

while getopts ":o:n:h" opt; do
  case "${opt}" in
    o)
      OUT_FILE="${OPTARG}"
      ;;
    n)
      NAMESPACE="${OPTARG}"
      ;;
    h)
      usage
      exit 0
      ;;
    :) 
      echo "Option -${OPTARG} requires an argument." >&2
      usage
      exit 1
      ;;
    \?)
      echo "Invalid option: -${OPTARG}" >&2
      usage
      exit 1
      ;;
  esac
done

shift $((OPTIND - 1))

if [[ "$#" -lt 1 ]]; then
  usage
  exit 1
fi

RECORDING_ID="$1"
if [[ -z "${OUT_FILE}" ]]; then
  OUT_FILE="recording-${RECORDING_ID}-merged.pcap"
fi

require_cmd kubectl
require_cmd mergecap
require_cmd mktemp

list_worker_pods() {
  local pods

  pods="$(kubectl -n "${NAMESPACE}" get pods -l app.kubernetes.io/name=worker -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null || true)"
  if [[ -n "${pods}" ]]; then
    printf '%s\n' "${pods}" | sed '/^$/d'
    return 0
  fi

  kubectl -n "${NAMESPACE}" get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' \
    | grep -E '^kubeshark-worker' || true
}

find_recording_pcaps() {
  local pod="$1"

  kubectl -n "${NAMESPACE}" exec "${pod}" -- sh -c '
set -eu
for d in /app/data /app /var/lib/kubeshark /tmp; do
  if [ -d "$d" ]; then
    find "$d" -type f -name "*.pcap" 2>/dev/null || true
  fi
done
' | grep -F "${RECORDING_ID}" || true
}

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

mapfile -t WORKER_PODS < <(list_worker_pods)
if [[ "${#WORKER_PODS[@]}" -eq 0 ]]; then
  echo "No Kubeshark worker pods found in namespace '${NAMESPACE}'." >&2
  exit 1
fi

echo "Found ${#WORKER_PODS[@]} worker pod(s) in namespace '${NAMESPACE}'."

copied=0
for pod in "${WORKER_PODS[@]}"; do
  mapfile -t remote_pcaps < <(find_recording_pcaps "${pod}")

  if [[ "${#remote_pcaps[@]}" -eq 0 ]]; then
    continue
  fi

  echo "${pod}: found ${#remote_pcaps[@]} matching pcap file(s)."

  pod_dir="${TMP_DIR}/${pod}"
  mkdir -p "${pod_dir}"

  for remote_pcap in "${remote_pcaps[@]}"; do
    base_name="$(basename "${remote_pcap}")"
    dest_path="${pod_dir}/${base_name}"

    kubectl cp "${NAMESPACE}/${pod}:${remote_pcap}" "${dest_path}" >/dev/null
    copied=$((copied + 1))
  done
done

if [[ "${copied}" -eq 0 ]]; then
  echo "No pcap files found for recording '${RECORDING_ID}' in namespace '${NAMESPACE}'." >&2
  exit 1
fi

mapfile -t local_pcaps < <(find "${TMP_DIR}" -type f -name '*.pcap' | sort)
if [[ "${#local_pcaps[@]}" -eq 0 ]]; then
  echo "No local pcap files were copied; cannot merge." >&2
  exit 1
fi

mergecap -w "${OUT_FILE}" "${local_pcaps[@]}"

echo "Merged ${#local_pcaps[@]} pcap file(s) into '${OUT_FILE}'."
