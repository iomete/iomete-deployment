resource "kubectl_manifest" "kafka_node_pool" {
  yaml_body = yamlencode({
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaNodePool"
    metadata = {
      name      = "${var.cluster_name}-pool"
      namespace = var.namespace
      labels = {
        "strimzi.io/cluster" = var.cluster_name
      }
    }
    spec = {
      replicas = var.kafka_replicas
      roles    = ["controller", "broker"]
      storage = {
        type        = "persistent-claim"
        size        = var.kafka_storage_size
        deleteClaim = var.delete_claim_on_destroy
      }
      resources = {
        requests = {
          memory = var.kafka_memory_request
          cpu    = var.kafka_cpu_request
        }
        limits = {
          memory = var.kafka_memory_limit
          cpu    = var.kafka_cpu_limit
        }
      }
    }
  })

  depends_on = [var.operator_dependency]
}

resource "kubectl_manifest" "kafka_cluster" {
  yaml_body = yamlencode({
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "Kafka"
    metadata = {
      name      = var.cluster_name
      namespace = var.namespace
      annotations = {
        "strimzi.io/kraft"      = "enabled"
        "strimzi.io/node-pools" = "enabled"
      }
    }
    spec = {
      kafka = {
        version = var.kafka_version

        listeners = [
          {
            name = "plain"
            port = 9092
            type = "internal"
            tls  = false
          },
          {
            name = "tls"
            port = 9093
            type = "internal"
            tls  = true
          }
        ]

        config = {
          "offsets.topic.replication.factor"         = tostring(var.kafka_replicas)
          "transaction.state.log.replication.factor" = tostring(var.kafka_replicas)
          "transaction.state.log.min.isr"            = tostring(min(2, var.kafka_replicas))
          "default.replication.factor"               = tostring(var.kafka_replicas)
          "min.insync.replicas"                      = tostring(min(2, var.kafka_replicas))
        }
      }

      entityOperator = {
        topicOperator = {
          resources = {
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
        userOperator = {
          resources = {
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
  })

  depends_on = [kubectl_manifest.kafka_node_pool]
}

resource "kubectl_manifest" "kafka_topic_test" {
  count = var.create_test_topic ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaTopic"
    metadata = {
      name      = "test-topic"
      namespace = var.namespace
      labels = {
        "strimzi.io/cluster" = var.cluster_name
      }
    }
    spec = {
      partitions = 3
      replicas   = min(3, var.kafka_replicas)
      config = {
        "retention.ms" = "604800000" # 7 days
      }
    }
  })

  depends_on = [kubectl_manifest.kafka_cluster]
}

resource "kubectl_manifest" "kafka_topic_events" {
  yaml_body = yamlencode({
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaTopic"
    metadata = {
      name      = "events"
      namespace = var.namespace
      labels = {
        "strimzi.io/cluster" = var.cluster_name
      }
    }
    spec = {
      partitions = 3
      replicas   = min(3, var.kafka_replicas)
      config = {
        "retention.ms" = "7200000" # 2 hours
        "segment.ms"   = "3600000" # 1 hour segments
      }
    }
  })

  depends_on = [kubectl_manifest.kafka_cluster]
}