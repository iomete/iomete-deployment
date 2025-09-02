resource "helm_release" "airflow" {
  name       = "airflow-chart"
  namespace  = var.namespace
  repository = var.chart_museum_url
  chart      = "airflow"
  version    = var.chart_version
  timeout    = 600

  values = [<<EOF
postgresql:
  enabled: false

data:
  metadataConnection:
    user: ${var.postgresql_username}
    pass: "${var.postgresql_password}"
    protocol: postgresql
    host: ${var.postgresql_host}
    port: ${var.postgresql_port}
    db: ${var.postgresql_database}
    sslmode: require

dags:
  persistence:
    enabled: false
  gitSync:
    enabled: false

config:
  core:
    hostname_callable: "socket:getfqdn"

createUserJob:
  useHelmHooks: false
  applyCustomEnv: false
migrateDatabaseJob:
  useHelmHooks: false
  applyCustomEnv: false

EOF
  ]
}