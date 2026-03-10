# AgentMatrix

AI Agents are increasingly complex, offering a variety of actions and endpoints, making it difficult to evaluate their actions and privacy/security risks. It is vital to provide sandboxed benchmarking and evaluation environments to assess their capabilities. 
AgentMatrix is a Kubernetes-first environment for running multiple containerized AI agents and inspecting how they interact over the the network.

This repository does not contain agent application code or model-serving logic. Instead, it provides the cluster configuration, sample workloads, and traffic-observability tooling needed to stand up an isolated local environment where agent-to-agent communication can be exercised and analyzed. The focus is on visibility: what services are talking, what requests are flowing between them, and how to capture those exchanges for debugging or demos.

For sample agentic applications to try on AgentMatrix please visit the equivalent [usecases repository](https://github.com/agentmatrix-project/application-scenarios)

## What This Repository Provides

- A local `kind`-based Kubernetes environment for reproducible demos.
- Cilium installation and configuration for service-level network visibility.
- Optional Kubeshark installation for full request and response payload inspection.
- Helper scripts to bootstrap the cluster and deploy applications
- Observability and analysis tooling to collect and process captured PCAP files.
- Sample client and server workloads in the `agents` namespace to generate HTTP traffic.

## How It Works

The repository is organized around a simple local workflow:

1. Create a local Kubernetes cluster with `kind`.
2. Install Cilium as the cluster networking layer.
3. Deploy demo workloads that continuously exchange HTTP traffic.
4. Use Kubeshark to inspect application payloads and export packet captures when needed.

For more information on how to use AgentMatrix refer to the [workflow manual](docs/workflow.md)

## Repository Layout

- `configs/` configuration values for local cluster and traffic tooling.
- `deploy/` Kubernetes manifests for the demo namespace and sample workloads.
- `docs/` setup and usage notes.
- `scripts/` helper scripts for preparing the cluster, installing Kubeshark, forwarding the UI, and collecting PCAP data.

## Quick Start

> Prepare the cluster:

```bash
scripts/prepare-cluster.sh
```

> Deploy the sample workloads:

```bash
kubectl apply -f deploy/
```

> Install Kubeshark:

```bash
scripts/install-kubeshark.sh
```

> Expose the Kubeshark UI locally:

```bash
scripts/run-kubeshark.sh
```

> When you want to merge packet captures for a recording:

```bash
scripts/collect-kubeshark-recording-pcap.sh <recording-id>
```

## Intended Use

AgentMatrix is best suited for:

- local demos of multi-agent communication patterns
- debugging service-to-service traffic inside Kubernetes
- validating observability tooling before deploying real agent images
- capturing network payloads for analysis and protocol experimentation

Current version is not yet a full production control plane. The current repository is intentionally scoped around local setup, visibility, and repeatable demonstrations.

## Documentation

- Setup guide: `docs/setup.md`
- Usage guide: `docs/workflow.md`
