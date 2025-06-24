resource "tls_private_key" "ca_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem   = tls_private_key.ca_key.private_key_pem
  is_ca_certificate = true

  subject {
    common_name  = "minio"
    organization = "minio"
  }

  validity_period_hours = 8760  # 1 year
  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}

resource "tls_private_key" "minio_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "minio_req" {
  private_key_pem = tls_private_key.minio_key.private_key_pem

  subject {
    common_name  = "minio.${var.namespace}.svc.cluster.local"
    organization = "minio"
  }

  dns_names = [
    "minio",
    "minio.${var.namespace}",
    "minio.${var.namespace}.svc",
    "minio.${var.namespace}.svc.cluster.local",
    "localhost",
  ]
}

resource "tls_locally_signed_cert" "minio_cert" {
  cert_request_pem   = tls_cert_request.minio_req.cert_request_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 8760  # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

resource "kubernetes_secret" "minio_tls" {
  metadata {
    name      = "minio-tls"
    namespace = var.namespace
  }

  data = {
    "public.crt"  = tls_locally_signed_cert.minio_cert.cert_pem
    "private.key" = tls_private_key.minio_key.private_key_pem
    "ca.crt"      = tls_self_signed_cert.ca_cert.cert_pem
  }

  type = "Opaque"
}