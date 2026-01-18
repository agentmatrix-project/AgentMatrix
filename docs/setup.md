# Environment Setup

This guide installs the local dependencies needed to run the demo cluster and capture traffic.

## Prerequisites

- `docker`
- `kind`
- `kubectl`
- `helm`
- `kubeshark`

Ensure Docker is running before bootstrapping the cluster.

## macOS (Homebrew)

```bash
brew install kind kubectl helm kubeshark docker
```

## Ubuntu/Debian

```bash
sudo apt-get update
sudo apt-get install -y docker.io
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-linux-amd64
chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl
curl -fsSL https://raw.githubusercontent.com/kubeshark/kubeshark/master/install.sh | bash
```

## Kubeshark via Helm (Optional)

Use this when you want a pinned, repeatable install in a shared cluster or GitOps workflow.

```bash
helm repo add kubeshark https://helm.kubeshark.co
helm repo update
helm install kubeshark kubeshark/kubeshark --namespace kubeshark --create-namespace
```

## Next Steps

- Bootstrap the cluster: `scripts/bootstrap-demo.sh`.
- Capture payloads: `scripts/start-kubeshark.sh`.
- Tear down the cluster: `kind delete cluster --name agent-matrix`.
