output "namespace" {
  description = "Namespace where the observability addons were installed."
  value       = var.namespace
}

output "installed_addons" {
  description = "Map of addon name to whether it was installed."
  value = {
    kiali      = var.enable.kiali
    prometheus = var.enable.prometheus
    grafana    = var.enable.grafana
    jaeger     = var.enable.jaeger
  }
}

output "prometheus_url" {
  description = "In-cluster Prometheus service URL, when Prometheus is enabled."
  value       = var.enable.prometheus ? "http://prometheus-server.${var.namespace}.svc:80" : null
}
