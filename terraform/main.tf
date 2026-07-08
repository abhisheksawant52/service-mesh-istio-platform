locals {
  istio_charts_repo = "https://istio-release.storage.googleapis.com/charts"

  # meshConfig shared by all istiod control planes that join the same mesh.
  mesh_config = {
    defaultConfig = {
      proxyMetadata = {
        ISTIO_META_DNS_CAPTURE       = "true"
        ISTIO_META_DNS_AUTO_ALLOCATE = "true"
      }
    }
    enableAutoMtls = true
    trustDomain    = var.trust_domain
  }
}

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = var.istio_namespace
    labels = merge(var.labels, {
      "topology.istio.io/network" = var.network
    })
  }
}

# Istio CRDs and cluster-wide resources.
resource "helm_release" "base" {
  name       = "istio-base"
  repository = local.istio_charts_repo
  chart      = "base"
  version    = var.istio_version
  namespace  = kubernetes_namespace.istio_system.metadata[0].name

  values = [file("${path.module}/../helm/values/base-values.yaml")]

  set {
    name  = "defaultRevision"
    value = var.revision
  }
}

# Istio control plane (istiod).
resource "helm_release" "istiod" {
  name       = "istiod"
  repository = local.istio_charts_repo
  chart      = "istiod"
  version    = var.istio_version
  namespace  = kubernetes_namespace.istio_system.metadata[0].name

  values = [file("${path.module}/../helm/values/istiod-values.yaml")]

  set {
    name  = "revision"
    value = var.revision
  }

  set {
    name  = "global.meshID"
    value = var.mesh_id
  }

  set {
    name  = "global.multiCluster.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "global.network"
    value = var.network
  }

  set {
    name  = "pilot.replicaCount"
    value = var.istiod_replicas
  }

  set {
    name  = "meshConfig.trustDomain"
    value = var.trust_domain
  }

  depends_on = [helm_release.base]
}

# North-south ingress gateway.
resource "helm_release" "ingress_gateway" {
  count = var.enable_ingress_gateway ? 1 : 0

  name       = "istio-ingressgateway"
  repository = local.istio_charts_repo
  chart      = "gateway"
  version    = var.istio_version
  namespace  = kubernetes_namespace.istio_system.metadata[0].name

  values = [file("${path.module}/../helm/values/gateway-values.yaml")]

  set {
    name  = "revision"
    value = var.revision
  }

  depends_on = [helm_release.istiod]
}

module "addons" {
  source = "./modules/istio-addons"
  count  = var.enable_addons ? 1 : 0

  namespace     = kubernetes_namespace.istio_system.metadata[0].name
  istio_version = var.istio_version
  enable        = var.addons
  labels        = var.labels

  depends_on = [helm_release.istiod]
}
