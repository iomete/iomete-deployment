resource "helm_release" "iomete_crds" {
  name       = "data-plane-crds"
  namespace  = var.namespace
  repository = var.iomete_chart_museum_url
  chart      = "iomete-data-plane-crds"
  version    = var.iomete_dataplane_crds_chart_version
}