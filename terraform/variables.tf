variable "kubeconfig_path" {
  description = "Path to the kubeconfig file used to reach the target cluster."
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Name of the kubeconfig context to target for this cluster."
  type        = string
}

variable "istio_version" {
  description = "Istio chart/app version to install (must match the istio-release chart repo)."
  type        = string
  default     = "1.22.3"
}

variable "istio_namespace" {
  description = "Namespace that hosts the Istio control plane."
  type        = string
  default     = "istio-system"
}

variable "revision" {
  description = "Istio control-plane revision label, used for canary upgrades and revision tags."
  type        = string
  default     = "default"
}

variable "mesh_id" {
  description = "Unique identifier shared by all control planes that belong to the same mesh."
  type        = string
  default     = "mesh1"
}

variable "cluster_name" {
  description = "Cluster identifier registered with the mesh (Istio clusterName / topology label)."
  type        = string
  default     = "cluster1"
}

variable "network" {
  description = "Network label for this cluster, used for cross-network east-west routing."
  type        = string
  default     = "network1"
}

variable "trust_domain" {
  description = "SPIFFE trust domain shared across the mesh for workload identity."
  type        = string
  default     = "cluster.local"
}

variable "istiod_replicas" {
  description = "Number of istiod control-plane replicas."
  type        = number
  default     = 2
}

variable "enable_ingress_gateway" {
  description = "Install the north-south ingress gateway (istio-ingressgateway)."
  type        = bool
  default     = true
}

variable "enable_eastwest_gateway" {
  description = "Install the east-west gateway used for cross-cluster traffic."
  type        = bool
  default     = false
}

variable "enable_addons" {
  description = "Install the observability addons module (kiali, prometheus, grafana, jaeger)."
  type        = bool
  default     = true
}

variable "addons" {
  description = "Toggle individual observability addons installed by the istio-addons module."
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

variable "labels" {
  description = "Common labels applied to namespaces and resources managed by this configuration."
  type        = map(string)
  default = {
    "app.kubernetes.io/managed-by" = "terraform"
    "app.kubernetes.io/part-of"    = "service-mesh-istio-platform"
  }
}
