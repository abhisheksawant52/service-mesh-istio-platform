# Installation

This guide installs Istio onto an **existing** Kubernetes cluster using the
Terraform config in [`terraform/`](../terraform). Terraform drives the Helm
provider against the Istio release chart repository.

## Prerequisites

- An existing Kubernetes cluster (v1.27+) and a kubeconfig context for it.
- Terraform >= 1.5.0.
- `kubectl` and (for multi-cluster) `istioctl` matching the target Istio
  version.
- Cluster-admin permissions for the target context.

## 1. Configure variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: set kube_context, istio_version, mesh_id, network, ...
```

Key variables (full list in [`terraform/variables.tf`](../terraform/variables.tf)):

| Variable        | Purpose                                      |
| --------------- | -------------------------------------------- |
| `kube_context`  | kubeconfig context to install into           |
| `istio_version` | Istio chart/app version                      |
| `mesh_id`       | Shared mesh identifier (multi-cluster)       |
| `network`       | Per-cluster network label                    |
| `enable_addons` | Install the observability stack              |

## 2. Initialize and validate

```bash
terraform init                       # or: -backend-config=environments/dev/backend.hcl
terraform fmt -check -recursive
terraform validate
```

## 3. Plan and apply

```bash
terraform plan  -var-file=environments/dev/dev.tfvars
terraform apply -var-file=environments/dev/dev.tfvars
```

This creates the `istio-system` namespace and installs `istio-base`, `istiod`,
the ingress gateway, and (when enabled) the observability addons.

## 4. Verify the control plane

```bash
kubectl -n istio-system get pods
kubectl -n istio-system rollout status deploy/istiod
istioctl version
```

## 5. Enable sidecar injection

Label application namespaces so new pods get the Envoy sidecar:

```bash
kubectl label namespace my-app istio-injection=enabled
# or, when using a revision:
kubectl label namespace my-app istio.io/rev=default --overwrite
```

## 6. Observability & telemetry

```bash
kubectl apply -f observability/telemetry.yaml
kubectl -n istio-system port-forward svc/kiali 20001:20001
```

## Multi-cluster

To join additional clusters into the mesh, follow
[`multi-cluster.md`](multi-cluster.md).

## Uninstall

```bash
terraform destroy -var-file=environments/dev/dev.tfvars
```
