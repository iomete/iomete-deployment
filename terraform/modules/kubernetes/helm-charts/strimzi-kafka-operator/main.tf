resource "helm_release" "strimzi_kafka_operator" {
  name       = "strimzi-kafka-operator"
  namespace  = var.namespace
  repository = "https://strimzi.io/charts/"
  chart      = "strimzi-kafka-operator"
  version    = var.strimzi_operator_version

  values = [
    yamlencode({
      watchAnyNamespace = var.watch_any_namespace

      resources = {
        limits = {
          memory = var.operator_memory_limit
          cpu    = var.operator_cpu_limit
        }
        requests = {
          memory = var.operator_memory_request
          cpu    = var.operator_cpu_request
        }
      }

      replicas = var.operator_replicas

      logLevel = var.log_level
    })
  ]
}