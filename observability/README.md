# Observability

The mesh ships with a full telemetry stack. The addons are installed by the
Terraform module [`terraform/modules/istio-addons`](../terraform/modules/istio-addons)
(toggled with `enable_addons` / the `addons` map). The values files here are the
canonical override values used by that module and by any manual `helm install`.

| Component  | Role                                    | Values file             |
| ---------- | --------------------------------------- | ----------------------- |
| Prometheus | Metrics scraping & storage              | `prometheus-values.yaml`|
| Grafana    | Dashboards (golden signals, control plane) | `grafana-values.yaml`   |
| Jaeger     | Distributed tracing backend             | `jaeger-values.yaml`    |
| Kiali      | Mesh topology & config console          | `kiali-values.yaml`     |

`telemetry.yaml` is a mesh-wide `Telemetry` custom resource enabling Prometheus
metrics, Envoy access logging, and 10% trace sampling to Jaeger. Apply it after
the control plane and addons are up:

```bash
kubectl apply -f observability/telemetry.yaml
```

Install a single addon manually (Terraform normally does this for you):

```bash
helm upgrade --install prometheus prometheus-community/prometheus \
  -n istio-system -f observability/prometheus-values.yaml
```

All service URLs are consistent across the Kiali config, Grafana datasource, and
the Terraform module outputs (`prometheus-server.istio-system.svc`).
