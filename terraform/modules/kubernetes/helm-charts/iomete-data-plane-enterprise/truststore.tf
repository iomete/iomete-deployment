locals {
  truststore_file_name = "truststore.jks"
}


resource "random_password" "truststore_password" {
  length  = 12
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "jks_trust_store" "truststore" {
  certificates = var.certificates
  password = random_password.truststore_password.result
}

resource "kubernetes_secret" "java-truststore" {
  metadata {
    name      = "java-truststore"
    namespace = var.namespace
  }

  binary_data = {
    (local.truststore_file_name) = jks_trust_store.truststore.jks
  }
  type = "Opaque"
}