# Single-node Apache Ozone with an S3 Gateway, installed from the Apache Ozone Helm chart.
#
# One datanode stores one copy of each object, so there is no redundancy beyond the disk
# itself. Ozone runs without Kerberos, so the S3 Gateway accepts any access/secret key pair.
# It is only reachable inside the cluster. IOMETE uses it over HTTPS with a self-signed
# certificate (tls.tf). For testing, not production.

locals {
  # The chart's S3 Service only exposes the HTTP port, so HTTPS gets a Service of its own.
  s3_https_service_name = "${var.release_name}-s3g-https"
  s3_https_port         = 9879
  s3_endpoint           = "https://${local.s3_https_service_name}.${var.namespace}.svc.cluster.local:${local.s3_https_port}"

  # The chart mounts configuration.filesFrom here, in every Ozone pod.
  config_dir = "/opt/hadoop/etc/hadoop"

  keystore_password_env = {
    valueFrom = {
      secretKeyRef = {
        name = kubernetes_secret_v1.ozone_tls.metadata[0].name
        key  = "keystore-password"
      }
    }
  }

  persistence = {
    enabled          = true
    storageClassName = kubernetes_storage_class_v1.ozone_storage_class.metadata[0].name
  }

  jvm_resources = {
    requests = { cpu = "250m", memory = "1Gi" }
    limits   = { memory = "2Gi" }
  }

  ozone_values = {
    image = {
      repository = var.image_repository
      tag        = var.image_tag
    }

    # Ozone runs as user "hadoop" (UID/GID 1000). fsGroup gives it write access to its
    # volumes, which are created owned by root.
    securityContext = {
      fsGroup             = 1000
      fsGroupChangePolicy = "OnRootMismatch"
    }

    env = [
      # Keep one copy of each object, since there is only one datanode.
      { name = "OZONE-SITE.XML_ozone.replication", value = "1" },
      { name = "OZONE-SITE.XML_ozone.server.default.replication", value = "1" },
      # The chart hardcodes hdds.scm.safemode.min.datanode=3, and a second env entry with the
      # same name is rejected by Helm 4 server-side apply. A single datanode never satisfies
      # it, so disable safe mode instead.
      { name = "OZONE-SITE.XML_hdds.scm.safemode.enabled", value = "false" },
      # Each datanode keeps 20GB free per volume by default, which is more than small volumes have.
      { name = "OZONE-SITE.XML_hdds.datanode.volume.min.free.space", value = "2GB" },

      # HTTPS next to HTTP. HTTPS_ONLY would break the chart's probes, which use plain HTTP.
      { name = "OZONE-SITE.XML_ozone.http.policy", value = "HTTP_AND_HTTPS" },
      { name = "OZONE-SITE.XML_ozone.s3g.https-address", value = "0.0.0.0:${local.s3_https_port}" },

      # The image turns <FILE>.<EXT>_<key> variables into config files, so these become
      # ssl-server.xml and ssl-client.xml on Ozone's classpath.
      { name = "SSL-SERVER.XML_ssl.server.keystore.location", value = "${local.config_dir}/keystore.jks" },
      { name = "SSL-SERVER.XML_ssl.server.keystore.type", value = "jks" },
      merge({ name = "SSL-SERVER.XML_ssl.server.keystore.password" }, local.keystore_password_env),
      merge({ name = "SSL-SERVER.XML_ssl.server.keystore.keypassword" }, local.keystore_password_env),
      { name = "SSL-CLIENT.XML_ssl.client.truststore.location", value = "${local.config_dir}/truststore.jks" },
      { name = "SSL-CLIENT.XML_ssl.client.truststore.type", value = "jks" },
      merge({ name = "SSL-CLIENT.XML_ssl.client.truststore.password" }, local.keystore_password_env),
    ]

    configuration = {
      filesFrom = [{
        secret = {
          name = kubernetes_secret_v1.ozone_tls.metadata[0].name
          items = [
            { key = "keystore.jks", path = "keystore.jks" },
            { key = "truststore.jks", path = "truststore.jks" },
            { key = "ca.crt", path = "ca.crt" },
          ]
        }
      }]
    }

    om = {
      replicas    = 1
      persistence = merge(local.persistence, { size = var.metadata_storage_size })
      resources   = local.jvm_resources
    }

    scm = {
      replicas    = 1
      persistence = merge(local.persistence, { size = var.metadata_storage_size })
      resources   = local.jvm_resources
    }

    datanode = {
      replicas    = 1
      persistence = merge(local.persistence, { size = var.datanode_storage_size })
      resources   = local.jvm_resources
    }

    s3g = {
      replicas = 1
      resources = {
        requests = { cpu = "100m", memory = "512Mi" }
        limits   = { memory = "1Gi" }
      }
    }

    # Recon is Ozone's web UI (port 9888): cluster health, datanodes, pipelines and a
    # namespace browser. It keeps its data inside the container and rebuilds it from the
    # Ozone Manager after a restart. The chart offers no resources setting for it.
    recon = {
      enabled = var.recon_enabled
    }
  }
}

resource "random_password" "s3_secret_key" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "kubernetes_storage_class_v1" "ozone_storage_class" {
  metadata {
    name = "ozone-storage-class"
  }

  storage_provisioner = var.kubernetes_storage_provisioner
  parameters          = var.storage_class_parameters

  reclaim_policy = "Delete"
  # The chart's StatefulSets create the claims, so binding can wait for their pods and the
  # disks land in the pods' zones.
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "helm_release" "ozone" {
  name       = var.release_name
  repository = var.chart_repository
  chart      = "ozone"
  version    = var.chart_version
  namespace  = var.namespace

  # SCM and OM initialise their metadata on first start, and the datanode waits for both.
  timeout = 900

  values = [yamlencode(local.ozone_values)]
}

resource "kubernetes_service_v1" "s3g_https" {
  metadata {
    name      = local.s3_https_service_name
    namespace = var.namespace
  }

  spec {
    type = "ClusterIP"

    selector = {
      "app.kubernetes.io/name"      = "ozone"
      "app.kubernetes.io/instance"  = var.release_name
      "app.kubernetes.io/component" = "s3g"
    }

    port {
      name        = "https"
      port        = local.s3_https_port
      target_port = local.s3_https_port
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_secret_v1" "ozone_s3_credentials" {
  metadata {
    name      = "ozone-s3-credentials"
    namespace = var.namespace
  }

  data = {
    AWS_ACCESS_KEY_ID     = var.s3_access_key
    AWS_SECRET_ACCESS_KEY = random_password.s3_secret_key.result
  }

  type = "Opaque"
}

resource "kubernetes_job_v1" "create_ozone_bucket" {
  metadata {
    name      = "create-ozone-bucket"
    namespace = var.namespace
  }

  spec {
    template {
      metadata {}
      spec {
        restart_policy = "OnFailure"

        container {
          name  = "ozone-bucket-creator"
          image = var.aws_cli_image

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.ozone_s3_credentials.metadata[0].name
            }
          }

          env {
            name  = "AWS_REGION"
            value = "us-east-1"
          }

          # Over HTTPS with the CA, so a TLS problem fails the apply here rather than in IOMETE.
          env {
            name  = "AWS_ENDPOINT_URL"
            value = local.s3_endpoint
          }

          env {
            name  = "AWS_CA_BUNDLE"
            value = "/etc/ozone-ca/ca.crt"
          }

          volume_mount {
            name       = "ozone-ca"
            mount_path = "/etc/ozone-ca"
            read_only  = true
          }

          command = [
            "/bin/sh",
            "-c",
            <<-EOF
              if aws s3api head-bucket --bucket ${var.bucket_name} 2>/dev/null; then
                echo "Bucket ${var.bucket_name} already exists"
              else
                aws s3 mb s3://${var.bucket_name}
              fi
            EOF
          ]
        }

        volume {
          name = "ozone-ca"
          secret {
            secret_name = kubernetes_secret_v1.ozone_tls.metadata[0].name
            items {
              key  = "ca.crt"
              path = "ca.crt"
            }
          }
        }
      }
    }

    completions   = 1
    backoff_limit = 3
  }

  # On a fresh node, pulling the AWS CLI image alone can take most of the provider's default
  # 1-minute wait, so the apply fails although the job completes moments later.
  wait_for_completion = true
  timeouts {
    create = "10m"
    update = "10m"
  }

  depends_on = [helm_release.ozone, kubernetes_service_v1.s3g_https]
}
