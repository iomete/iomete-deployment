resource "tls_private_key" "ca_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem = tls_private_key.ca_key.private_key_pem

  validity_period_hours = 8760 # 1 year
  is_ca_certificate = true

  subject {
    common_name = "spark-operator-webhook.${var.namespace}.svc"
  }

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
    "crl_signing"
  ]
}

resource "tls_private_key" "server_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "server_csr" {
  private_key_pem = tls_private_key.server_key.private_key_pem

  subject {
    common_name = "spark-operator-webhook.${var.namespace}.svc"
  }
  dns_names = ["spark-operator-webhook.${var.namespace}.svc"]
}

resource "tls_locally_signed_cert" "server_cert" {
  cert_request_pem   = tls_cert_request.server_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth"
  ]
}

resource "kubernetes_secret" "webhook_cert_secret" {
  metadata {
    name      = "spark-operator-webhook-certs"
    namespace = var.namespace
  }

  data = {
    "ca-cert.pem"     = tls_self_signed_cert.ca_cert.cert_pem
    "ca-key.pem"      = tls_private_key.ca_key.private_key_pem
    "server-cert.pem" = tls_locally_signed_cert.server_cert.cert_pem
    "server-key.pem"  = tls_private_key.server_key.private_key_pem
  }
}