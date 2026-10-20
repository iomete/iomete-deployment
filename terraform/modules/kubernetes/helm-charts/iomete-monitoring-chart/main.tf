resource "random_password" "grafana_admin_password" {
  length  = 16
  special = false
}

resource "helm_release" "iomete-monitoring" {
  name       = "iomete-monitoring-chart"
  namespace  = var.monitoring_namespace
  repository = var.iomete_chart_museum_url
  chart      = "iomete-monitoring-chart"
  version    = var.iomete_monitoring_chart_version

  values = [
    yamlencode({
      iometeSystemNamespace = var.control_plane_namespace

      grafana = {
        adminPassword = random_password.grafana_admin_password.result
      }

      database = {
        enabled = true
        host    = var.postgresql_host
        port    = var.postgresql_port

        adminCredentials = {
          user     = var.postgresql_user
          password = var.postgresql_password
        }

        ssl = {
          mode = "disable"
        }
      }
    })
  ]
}
