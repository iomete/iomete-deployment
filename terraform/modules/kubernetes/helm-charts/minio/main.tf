resource "random_password" "minio_root_password" {
  length  = 12
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "kubernetes_storage_class" "minio_storage_class" {
  metadata {
    name = "minio-storage-class"
  }

  storage_provisioner = var.kubernetes_storage_provisioner
  parameters = {
    skuname = "StandardSSD_LRS"
  }

  reclaim_policy      = "Delete"
  volume_binding_mode = "Immediate"  # If set to something else, this might cause terraform to hang on creation
}

resource "kubernetes_persistent_volume_claim" "minio_pvc" {
  metadata {
    name      = var.pvc_name
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.storage_size
      }
    }

    storage_class_name = kubernetes_storage_class.minio_storage_class.metadata[0].name
  }
}

# TODO: we should move this to use the helm chart for minio directly
resource "kubernetes_deployment" "minio" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      app = "minio"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "minio"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app = "minio"
        }
      }

      spec {
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.minio_pvc.metadata[0].name
          }
        }

        volume {
          name = "minio-tls"
          secret {
            secret_name = kubernetes_secret.minio_tls.metadata[0].name
          }
        }

        container {
          name  = "minio"
          image = "minio/minio:${var.minio_version}"

          args = [
            "server",
            "/data",
            "--console-address",
            ":9001"
          ]

          env {
            name  = "MINIO_ROOT_USER"
            value = var.minio_root_user
          }

          env {
            name  = "MINIO_ROOT_PASSWORD"
            value = random_password.minio_root_password.result
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
          }

          volume_mount {
            name       = "minio-tls"
            mount_path = "/root/.minio/certs"
            read_only  = true
          }

          port {
            name           = "s3-api"
            container_port = 9000
          }

          port {
            name           = "console"
            container_port = 9001
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "minio_service" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "minio"
    }

    port {
      name        = "s3-api"
      port        = 9000
      protocol    = "TCP"
      target_port = 9000
    }

    port {
      name        = "console"
      port        = 9001
      protocol    = "TCP"
      target_port = 9001
    }

    type = var.service_type
  }
}

resource "kubernetes_job" "create_minio_bucket" {
  metadata {
    name      = "create-minio-bucket"
    namespace = var.namespace
  }

  spec {
    template {
      metadata {}
      spec {
        restart_policy = "OnFailure"

        volume {
          name = "minio-tls"
          secret {
            secret_name = kubernetes_secret.minio_tls.metadata[0].name
          }
        }

        container {
          name  = "minio-bucket-creator"
          image = "minio/mc"

          volume_mount {
            name       = "minio-tls"
            mount_path = "/root/.mc/certs/CAs"
            read_only  = true
          }

          command = [
            "/bin/sh",
            "-c",
            <<-EOF
              mc alias set minio https://minio.${var.namespace}.svc.cluster.local:9000 ${var.minio_root_user} ${random_password.minio_root_password.result}
              if ! mc ls minio/lakehouse; then
                mc mb minio/lakehouse
              fi
            EOF
          ]
        }
      }
    }

    completions   = 1
    backoff_limit = 3
  }

  depends_on = [kubernetes_deployment.minio, kubernetes_service.minio_service]
}
