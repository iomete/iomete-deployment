resource "kubernetes_deployment" "kafka_ui" {
  metadata {
    name      = "kafka-ui"
    namespace = var.namespace
    labels = {
      app = "kafka-ui"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "kafka-ui"
      }
    }

    template {
      metadata {
        labels = {
          app = "kafka-ui"
        }
      }

      spec {
        container {
          name  = "kafka-ui"
          image = "provectuslabs/kafka-ui:latest"

          port {
            container_port = 8080
          }

          env {
            name  = "KAFKA_CLUSTERS_0_NAME"
            value = var.cluster_name
          }

          env {
            name  = "KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS"
            value = var.kafka_bootstrap_servers
          }

          env {
            name  = "KAFKA_CLUSTERS_0_READONLY"
            value = "false"
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "kafka_ui" {
  metadata {
    name      = "kafka-ui"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "kafka-ui"
    }

    port {
      name        = "http"
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}