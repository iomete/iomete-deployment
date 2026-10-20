# Self-signed TLS for Ozone: Terraform creates a CA, signs a server certificate with it,
# and hands the CA to IOMETE (output ca_cert_pem) so its services trust the S3 Gateway.
#
# ozone.http.policy is global, so every Ozone component serves HTTPS next to HTTP and needs the
# keystore. The truststore holds the CA for Ozone's own HTTPS clients, such as Recon fetching
# the Ozone Manager's database.

locals {
  headless_hosts = [
    for component in ["om", "scm", "datanode", "s3g"] :
    "*.${var.release_name}-${component}-headless.${var.namespace}.svc.cluster.local"
  ]

  service_hosts = flatten([
    for service in [local.s3_https_service_name, "${var.release_name}-recon"] : [
      service,
      "${service}.${var.namespace}",
      "${service}.${var.namespace}.svc",
      "${service}.${var.namespace}.svc.cluster.local",
    ]
  ])
}

# No special characters: Ozone's config files are generated from these values.
resource "random_password" "keystore_password" {
  length  = 24
  special = false
}

resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem   = tls_private_key.ca.private_key_pem
  is_ca_certificate = true

  subject {
    common_name  = "${var.release_name}-ca"
    organization = "IOMETE sample"
  }

  validity_period_hours = var.certificate_validity_hours
  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}

resource "tls_private_key" "server" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem

  subject {
    common_name  = "${local.s3_https_service_name}.${var.namespace}.svc.cluster.local"
    organization = "IOMETE sample"
  }

  # The S3 Gateway's Service, every component's pod hostname, and localhost for port-forwarding.
  dns_names = concat(local.service_hosts, local.headless_hosts, ["localhost"])
}

resource "tls_locally_signed_cert" "server" {
  cert_request_pem   = tls_cert_request.server.cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = var.certificate_validity_hours
  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

# The key entry uses the store password, so one password serves both ssl.server settings.
resource "jks_key_store" "keystore" {
  certificate_chain = [tls_locally_signed_cert.server.cert_pem, tls_self_signed_cert.ca.cert_pem]
  private_key       = tls_private_key.server.private_key_pem_pkcs8
  password          = random_password.keystore_password.result
}

resource "jks_trust_store" "truststore" {
  certificates = [tls_self_signed_cert.ca.cert_pem]
  password     = random_password.keystore_password.result
}

# Mounted into every Ozone pod's configuration directory through the chart's
# configuration.filesFrom, and read by the bucket Job for the CA.
resource "kubernetes_secret_v1" "ozone_tls" {
  metadata {
    name      = "${var.release_name}-tls"
    namespace = var.namespace
  }

  binary_data = {
    "keystore.jks"   = jks_key_store.keystore.jks
    "truststore.jks" = jks_trust_store.truststore.jks
  }

  data = {
    "ca.crt"            = tls_self_signed_cert.ca.cert_pem
    "keystore-password" = random_password.keystore_password.result
  }

  type = "Opaque"
}
