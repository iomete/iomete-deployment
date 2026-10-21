# The certificates IOMETE trusts: Mozilla's public CA bundle plus var.certificates, such as the
# CA of self-signed object storage. The public CAs are needed too, because the truststore
# replaces the JVM's default one, so it must still trust public HTTPS endpoints.
#
# The chart reads it from the Secret in two forms: truststore.jks for the Java services and
# Spark, and ca.crt (PEM) for the services that can't read a JKS: the lakehouse agent, the
# gateway and the Prefect worker.

locals {
  truststore_enabled   = length(var.certificates) > 0
  truststore_file_name = "truststore.jks"
  ca_cert_file_name    = "ca.crt"
  truststore_mount     = "/etc/ssl/iomete-certs"

  public_ca_certificates = local.truststore_enabled ? [
    for cert in regexall("-----BEGIN CERTIFICATE-----[\\s\\S]*?-----END CERTIFICATE-----", data.http.mozilla_ca_bundle[0].response_body) :
    cert
  ] : []

  all_certificates = concat(local.public_ca_certificates, var.certificates)
}

data "http" "mozilla_ca_bundle" {
  count = local.truststore_enabled ? 1 : 0
  url   = "https://curl.se/ca/cacert.pem"
}

# No special characters: the chart puts it unquoted into the services' JVM arguments.
resource "random_password" "truststore_password" {
  count   = local.truststore_enabled ? 1 : 0
  length  = 24
  special = false
}

resource "jks_trust_store" "truststore" {
  count        = local.truststore_enabled ? 1 : 0
  certificates = local.all_certificates
  password     = random_password.truststore_password[0].result
}

resource "kubernetes_secret_v1" "java_truststore" {
  count = local.truststore_enabled ? 1 : 0

  metadata {
    name      = "java-truststore"
    namespace = var.namespace
  }

  binary_data = {
    (local.truststore_file_name) = jks_trust_store.truststore[0].jks
  }

  data = {
    (local.ca_cert_file_name) = join("\n", local.all_certificates)
  }

  type = "Opaque"
}
