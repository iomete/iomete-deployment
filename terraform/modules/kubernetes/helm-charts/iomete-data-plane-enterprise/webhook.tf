resource "kubernetes_mutating_webhook_configuration" "spark_operator_mutating_webhook" {
  depends_on = [kubernetes_role_binding.iomete_lakehouse_role_binding]

  metadata {
    name = "spark-operator-${var.namespace}"
  }
  webhook {
    name = "webhook.sparkoperator.k8s.io"
    client_config {
      service {
        namespace = var.namespace
        name      = "spark-operator-webhook"
        path      = "/mutate--v1-pod"
        port      = 443
      }
      ca_bundle = tls_self_signed_cert.ca_cert.cert_pem
    }
    rule {
      api_groups = [""]
      api_versions = ["v1"]
      operations  = ["CREATE"]
      resources = ["pods"]
      scope = "Namespaced"
    }
    failure_policy = "Ignore"
    match_policy = "Equivalent"

    namespace_selector {
      match_labels = {
        "iomete.com/managed" = "true"
      }
    }

    object_selector {}
    side_effects = "NoneOnDryRun"
    timeout_seconds = 30
    admission_review_versions = ["v1"]
    reinvocation_policy = "Never"
  }
}