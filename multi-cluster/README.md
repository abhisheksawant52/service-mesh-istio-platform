# Multi-Cluster Mesh

This directory contains the manifests and steps for joining multiple Kubernetes
clusters into a single Istio mesh using a **multi-primary on separate networks**
topology. Every cluster runs its own istiod control plane, shares the same mesh
identity (`mesh_id` + `trust_domain`), and exposes services to peers through an
**east-west gateway**.

## Topology

- Each cluster runs a full control plane (multi-primary) → no single point of
  failure.
- Clusters live on separate networks (`network1`, `network2`) → traffic between
  them flows through east-west gateways over mTLS (`AUTO_PASSTHROUGH`).
- A shared root CA issues intermediate CAs per cluster so workloads across
  clusters trust each other under the same `trustDomain`.

## Manifests

| File                        | Purpose                                                        |
| --------------------------- | -------------------------------------------------------------- |
| `cross-network-gateway.yaml`| LoadBalancer Service for the east-west gateway (port 15443).   |
| `east-west-gateway.yaml`    | `Gateway` exposing `*.local` via SNI auto-passthrough.         |
| `expose-services.yaml`      | `VirtualService` + `Sidecar` binding mesh services to peers.   |

## Prerequisites

1. A shared root CA installed into `istio-system` on every cluster (see
   [`docs/multi-cluster.md`](../docs/multi-cluster.md)).
2. Istio installed on each cluster via the Terraform config in
   [`terraform/`](../terraform/) with a unique `cluster_name`/`network` and a
   shared `mesh_id`.
3. `enable_eastwest_gateway = true` for participating clusters.

## Wiring clusters together

Label the control-plane namespace with the cluster's network and apply the
east-west gateway and exposure manifests:

```bash
# On each cluster (example: cluster1 / network1)
kubectl --context cluster1 label namespace istio-system \
  topology.istio.io/network=network1 --overwrite

kubectl --context cluster1 apply -f multi-cluster/
```

## Remote secret creation

For istiod on each cluster to discover endpoints on its peers, install a
**remote secret** — a kubeconfig granting read access to the peer's API server.
Generate it with `istioctl` (no secret values are stored in this repo):

```bash
# Grant cluster1's control plane access to cluster2 (and vice versa).
istioctl create-remote-secret \
  --context="cluster2" \
  --name=cluster2 | kubectl apply --context="cluster1" -f -

istioctl create-remote-secret \
  --context="cluster1" \
  --name=cluster1 | kubectl apply --context="cluster2" -f -
```

Verify endpoints are shared across clusters:

```bash
istioctl --context cluster1 proxy-config endpoints deploy/istiod -n istio-system
```

> The generated remote secret is a Kubernetes `Secret` labelled
> `istio/multiCluster=true`. Treat it as sensitive — never commit it.
