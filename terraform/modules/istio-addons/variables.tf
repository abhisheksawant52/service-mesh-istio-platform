variable "namespace" {
  description = "Namespace to install the observability addons into (typically istio-system)."
  type        = string
  default     = "istio-system"
}

variable "istio_version" {
  description = "Istio version, used to align addon manifests with the control plane."
  type        = string
}

variable "enable" {
  description = "Per-addon install toggles."
  type = object({
    kiali      = bool
    prometheus = bool
    grafana    = bool
    jaeger     = bool
  })
  default = {
    kiali      = true
    prometheus = true
    grafana    = true
    jaeger     = true
  }
}

variable "prometheus_chart_version" {
  description = "prometheus-community/prometheus chart version."
  type        = string
  default     = "25.24.0"
}

variable "grafana_chart_version" {
  description = "grafana/grafana chart version."
  type        = string
  default     = "8.3.4"
}

variable "kiali_chart_version" {
  description = "kiali/kiali-server chart version."
  type        = string
  default     = "1.86.0"
}

variable "jaeger_chart_version" {
  description = "jaegertracing/jaeger chart version."
  type        = string
  default     = "3.1.0"
}

variable "labels" {
  description = "Common labels applied to addon releases."
  type        = map(string)
  default     = {}
}
