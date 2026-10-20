resource "random_password" "iomete_admin_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

locals {
  values = merge({
    name = "iomete-data-plane"

    adminUser = {
      username          = "admin"
      email             = var.admin_email
      firstName         = "Admin"
      lastName          = "Admin"
      temporaryPassword = random_password.iomete_admin_password.result
    }

    database = {
      type     = "postgresql"
      host     = var.postgresql_host
      port     = tostring(var.postgresql_port)
      user     = var.postgresql_user
      password = var.postgresql_password
      prefix   = "iomete_"

      # Lets the chart create IOMETE's databases on install.
      adminCredentials = {
        user     = var.postgresql_admin_user
        password = var.postgresql_admin_password
      }

      ssl = {
        enabled = false
      }
    }

    storage = var.storage

    # The chart creates the lakehouse service account and its RBAC, the Spark Operator CRDs
    # and the Spark Operator webhook with its certificate.
    serviceAccount = { create = true }
    crds           = { create = true }
    webhook        = { create = true }

    # Plain HTTP behind kubectl port-forward. Turn on HTTPS once an ingress terminates TLS.
    ingress = {
      httpsEnabled = false
    }
  }, var.extra_values)
}

resource "helm_release" "iomete-system" {
  timeout    = 900 # 15 minutes
  name       = "data-plane"
  namespace  = var.namespace
  repository = var.iomete_chart_museum_url
  chart      = "iomete-data-plane-enterprise"
  version    = var.iomete_dataplane_enterprise_chart_version

  values = [yamlencode(local.values)]
}
