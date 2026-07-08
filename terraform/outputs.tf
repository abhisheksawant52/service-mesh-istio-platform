output "istio_namespace" {
  description = "Namespace hosting the Istio control plane."
  value       = kubernetes_namespace.istio_system.metadata[0].name
}

output "istio_version" {
  description = "Istio version installed on this cluster."
  value       = var.istio_version
}

output "revision" {
  description = "Istio control-plane revision label."
  value       = var.revision
}

output "mesh_id" {
  description = "Mesh identifier shared across all clusters in the mesh."
  value       = var.mesh_id
}

output "cluster_name" {
  description = "Cluster identifier registered with the mesh."
  value       = var.cluster_name
}

output "network" {
  description = "Network label assigned to this cluster."
  value       = var.network
}

output "ingress_gateway_release" {
  description = "Name of the ingress gateway Helm release, if enabled."
  value       = var.enable_ingress_gateway ? helm_release.ingress_gateway[0].name : null
}

output "addons_enabled" {
  description = "Whether the observability addons module was installed."
  value       = var.enable_addons
}
