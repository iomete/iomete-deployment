resource "kubernetes_deployment" "kafka_data_producer" {
  metadata {
    name      = "kafka-data-producer"
    namespace = var.namespace
    labels = {
      app = "kafka-data-producer"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "kafka-data-producer"
      }
    }

    template {
      metadata {
        labels = {
          app = "kafka-data-producer"
        }
      }

      spec {
        container {
          name  = "kafka-data-producer"
          image = "python:3.9-slim"

          command = ["/bin/bash"]
          args = [
            "-c",
            <<-EOF
              echo "Installing dependencies..."
              pip install kafka-python
              echo "Starting data producer..."
              python /scripts/producer.py
            EOF
          ]

          env {
            name  = "KAFKA_BOOTSTRAP_SERVERS"
            value = var.kafka_bootstrap_servers
          }

          env {
            name  = "KAFKA_TOPIC"
            value = var.topic_name
          }

          env {
            name  = "DATA_TYPE"
            value = var.data_type
          }

          env {
            name  = "MESSAGE_INTERVAL_SECONDS"
            value = tostring(var.message_interval_seconds)
          }

          volume_mount {
            name       = "producer-scripts"
            mount_path = "/scripts"
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

        volume {
          name = "producer-scripts"
          config_map {
            name         = kubernetes_config_map.producer_scripts.metadata[0].name
            default_mode = "0755"
          }
        }
      }
    }
  }
}