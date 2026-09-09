terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.0, < 3.3.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.27.0, < 3.0.0"
    }
  }
}

locals {
  addon_labels = merge(var.labels, {
    "app.kubernetes.io/component" = "observability"
  })
}

# Metrics scraping for the mesh.
resource "helm_release" "prometheus" {
  count = var.enable.prometheus ? 1 : 0

  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = var.prometheus_chart_version
  namespace  = var.namespace

  set {
    name  = "server.global.scrape_interval"
    value = "15s"
  }

  set {
    name  = "alertmanager.enabled"
    value = "false"
  }
}

# Dashboards for mesh golden signals.
resource "helm_release" "grafana" {
  count = var.enable.grafana ? 1 : 0

  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = var.grafana_chart_version
  namespace  = var.namespace

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "persistence.enabled"
    value = "false"
  }
}

# Distributed tracing backend.
resource "helm_release" "jaeger" {
  count = var.enable.jaeger ? 1 : 0

  name       = "jaeger"
  repository = "https://jaegertracing.github.io/helm-charts"
  chart      = "jaeger"
  version    = var.jaeger_chart_version
  namespace  = var.namespace

  set {
    name  = "provisionDataStore.cassandra"
    value = "false"
  }

  set {
    name  = "allInOne.enabled"
    value = "true"
  }

  set {
    name  = "storage.type"
    value = "memory"
  }
}

# Mesh topology and configuration console.
resource "helm_release" "kiali" {
  count = var.enable.kiali ? 1 : 0

  name       = "kiali-server"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"
  version    = var.kiali_chart_version
  namespace  = var.namespace

  set {
    name  = "auth.strategy"
    value = "anonymous"
  }

  set {
    name  = "external_services.prometheus.url"
    value = "http://prometheus-server.${var.namespace}.svc:80"
  }

  set {
    name  = "external_services.grafana.enabled"
    value = "true"
  }

  set {
    name  = "external_services.tracing.enabled"
    value = tostring(var.enable.jaeger)
  }

  depends_on = [
    helm_release.prometheus,
    helm_release.grafana,
    helm_release.jaeger,
  ]
}
