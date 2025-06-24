resource "random_password" "iomete_admin_password" {
  length  = 12
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "helm_release" "iomete-system" {
  depends_on = [
    kubernetes_role_binding.iomete_lakehouse_role_binding, kubernetes_mutating_webhook_configuration.spark_operator_mutating_webhook
  ]

  timeout    = 900 # 15 minutes
  name       = "data-plane"
  namespace  = var.namespace
  repository = var.iomete_chart_museum_url
  chart      = "iomete-data-plane-enterprise"
  version    = var.iomete_dataplane_enterprise_chart_version

  values = [
    yamlencode({
      name = "iomete-data-plane"

      adminUser = {
        username          = "admin"
        email             = "rocco.verhoef@iomete.com"
        firstName         = "admin"
        lastName          = "admin"
        temporaryPassword = random_password.iomete_admin_password.result
      }

      database = {
        type     = "postgresql"
        host     = var.postgresql_host
        port     = var.postgresql_port
        user     = var.postgresql_user
        password = var.postgresql_password
        prefix   = "iomete_"

        adminCredentials = {
          user     = var.postgresql_admin_user
          password = var.postgresql_admin_password
        }

        ssl = {
          enabled = false
          # mode = "verify-full" # optional, can be added if needed
        }
      }

      storage = {
        bucketName = "lakehouse"
        type       = "minio"

        minioSettings = {
          endpoint  = var.minio_uri
          accessKey = var.minio_username
          secretKey = var.minio_secret
        }
      }

      javaTrustStore = {
        enabled    = true
        secretName = kubernetes_secret.java-truststore.metadata[0].name
        fileName   = local.truststore_file_name
        password   = random_password.truststore_password.result
        mountPath  = "/etc/ssl/iomete-certs"
      }
    })
  ]
}
