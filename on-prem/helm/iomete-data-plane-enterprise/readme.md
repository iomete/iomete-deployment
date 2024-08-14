# IOMETE Data Plane Helm Enterprise Version

- **Helm Repository:** https://chartmuseum.iomete.com
- **Chart Name:** `iomete-data-plane-enterprise`
- **Latest Version:** `1.19.3`

## Quick Start

```shell
# Add IOMETE helm repo
helm repo add iomete https://chartmuseum.iomete.com
helm repo update

# Deploy IOMETE Data Plane (to customize the installation see the Configuration section)
helm upgrade --install -n iomete-system iomete-data-plane \
  iomete/iomete-data-plane-enterprise --version 1.19.3
```

## Configuration

### 1. General Configuration

| Name | Description                         | Default Value    | Available from Version |
| ---- | ----------------------------------- | ---------------- | ---------------------- |
| name | The unique name for the data plane. | iomete-community | 1.9.2                  |

### 2. Admin User

This is the user that will be created for the data plane admin. Additional users can be created later through the IOMETE
Data Plane UI. In most cases, the default values for the admin user are sufficient. If you need, you can change the
first name, last name, email, and temporary password. The `username` and `temporaryPassword` will be used for the first
login.

| Name                        | Description                                  | Default Value     | Available from Version |
| --------------------------- | -------------------------------------------- | ----------------- | ---------------------- |
| adminUser.username          | Username for the data plane admin user.      | admin             | 1.9.2                  |
| adminUser.email             | Email address for the data plane admin user. | admin@example.com | 1.9.2                  |
| adminUser.firstName         | First name of the admin user.                | Admin             | 1.9.2                  |
| adminUser.lastName          | Last name of the admin user.                 | Admin             | 1.9.2                  |
| adminUser.temporaryPassword | Temporary password for first login.          | admin             | 1.9.2                  |

### 3. Database Configuration

This section contains the configuration for the database used by the IOMETE Data Plane. The default values are set for a
PostgreSQL database, but you can adjust them to match your database configuration.

| Name                                                 | Description                                                                                                           | Default Value | Available from Version |
| ---------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | ------------- | ---------------------- |
| database.type                                        | Type of the database supported.                                                                                       | postgresql    | 1.9.2                  |
| database.host                                        | Hostname for the database.                                                                                            | postgresql    | 1.9.2                  |
| database.port                                        | Port on which the database server is listening.                                                                       | 5432          | 1.9.2                  |
| database.user                                        | Username to connect to the database.                                                                                  | iomete_user   | 1.9.2                  |
| database.password                                    | Password to connect to the database.                                                                                  | iomete_pass   | 1.9.2                  |
| [database.passwordSecret](#database-password-secret) | Name of the Kubernetes secret containing the database password. If this is set, the `password` field will be ignored. |               | 1.9.2                  |
| database.prefix                                      | Prefix to be added to all IOMETE databases. This is useful when multiple IOMETE instances share the same database.    | iomete_       | 1.9.2                  |
| database.ssl.enabled                                 | Enable SSL for database connections.                                                                                  | false         | 1.9.2                  |
| database.ssl.mode                                    | SSL mode for database connections.                                                                                    | disable       | 1.9.2                  |

#### Database Admin Credentials

When this section is provided, IOMETE will create all the necessary databases and users for the IOMETE Data Plane.
Remove this section if you want to handle the database setup manually.

| Name                                     | Description                                                                                                                 | Default Value | Available from Version |
| ---------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- | ------------- | ---------------------- |
| database.adminCredentials.user           | A database user which has rights to create databases, users, and grant privileges.                                          | postgres      | 1.9.2                  |
| database.adminCredentials.password       | Password for the database admin user.                                                                                       |               | 1.9.2                  |
| database.adminCredentials.passwordSecret | Name of the Kubernetes secret containing the database admin password. If this is set, the `password` field will be ignored. |               | 1.9.2                  |

### 4. Spark Configuration

| Name           | Description                               | Default Value | Available from Version |
| -------------- | ----------------------------------------- | ------------- | ---------------------- |
| spark.logLevel | Default log level for Spark applications. | warn          | 1.9.2                  |

### 5. Keycloak Configuration

Keycloak is the identity provider used for authentication and user management in the IOMETE Data Plane.

| Name                                                            | Description                                                                                                                      | Default Value             | Available from Version |
| --------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ------------------------- | ---------------------- |
| keycloak.enabled                                                | Enable or disable Keycloak authentication.                                                                                       | true                      | 1.9.2                  |
| keycloak.adminUser                                              | Username for Keycloak admin.                                                                                                     | kc_admin                  | 1.9.2                  |
| keycloak.adminPassword                                          | Password for Keycloak admin.                                                                                                     | Admin_123                 | 1.9.2                  |
| [keycloak.adminPasswordSecret](#keycloak-admin-password-secret) | Name of the Kubernetes secret containing the Keycloak admin password. If this is set, the `adminPassword` field will be ignored. |                           | 1.9.2                  |
| keycloak.endpoint                                               | Endpoint URL for Keycloak service. Only change this if you are using a custom Keycloak instance.                                 | http://keycloak-http/auth | 1.9.2                  |

### 6. Storage Configuration

Configure the storage backend for the IOMETE Data Plane.

| Name                                                  | Description                                                                | Default Value | Available from Version |
| ----------------------------------------------------- | -------------------------------------------------------------------------- | ------------- | ---------------------- |
| storage.bucketName                                    | Name of the bucket to be used.                                             | lakehouse     | 1.9.2                  |
| storage.type                                          | Type of storage backend. Options: minio, dell_ecs, aws_s3, gcs, azure_gen1 | minio         | 1.9.2                  |
| [storage.dellEcsSettings](#dell-ecs-storage-settings) | Settings for Dell ECS storage.                                             | {}            | 1.9.2                  |
| [storage.minioSettings](#minio-storage-settings)      | Settings for MinIO storage.                                                | {}            | 1.9.2                  |

### 7. Cluster and Docker Configuration

| Name                                                  | Description                                                                                              | Default Value | Available from Version |
| ----------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | ------------- | ---------------------- |
| clusterDomain                                         | Kubernetes cluster domain.                                                                               | cluster.local | 1.9.2                  |
| docker.repo                                           | Docker repository for pulling images. If you want to use a custom repository, you can change this value. | iomete        | 1.9.2                  |
| docker.sparkVersion                                   | Spark version for the Docker image.                                                                      | 3.5.1-v2      | 1.9.2                  |
| docker.pullPolicy                                     | Pull policy for Docker images.                                                                           | Always        | 1.9.2                  |
| [docker.imagePullSecrets](#docker-image-pull-secrets) | Image pull secrets for Docker images.                                                                    | []            | 1.9.2                  |

### 8. Jupyter Gateway Configuration

Jupyter Gateway is a service that provides a remote Jupyter notebook kernel for Spark and Scala.

| Name                   | Description                                   | Default Value                      | Available from Version |
| ---------------------- | --------------------------------------------- | ---------------------------------- | ---------------------- |
| jupyterGateway.kernels | List of kernels available in Jupyter Gateway. | pyspark_kernel, spark_scala_kernel | 1.9.2                  |

### 9. Data Catalog Configuration

| Name                     | Description                                                                                                 | Default Value | Available from Version |
| ------------------------ | ----------------------------------------------------------------------------------------------------------- | ------------- | ---------------------- |
| dataCatalog.enabled      | Enable or disable the data catalog feature.                                                                 | true          | 1.9.2                  |
| dataCatalog.storageSize  | Allocated memory for Typesense search engine storage                                                        | 1Gi           | 1.9.2                  |
| dataCatalog.piiDetection | This enables the PII detection feature in the data catalog. It will also install the Presidio Docker image. | false         | 1.11.0                 |

### 10. Data Security Module (Ranger) Configuration

| Name                 | Description                                | Default Value | Available from Version |
| -------------------- | ------------------------------------------ | ------------- | ---------------------- |
| ranger.enabled       | Enable or disable the Ranger module.       | true          | 1.9.2                  |
| ranger.audit.enabled | Enable or disable audit logging in Ranger. | false         | 1.10.0                 |

### 11. Monitoring Configuration

Set `true` if Prometheus stack is installed in the cluster. You can install it with a separate Helm chart.

| Name               | Description                   | Default Value | Available from Version |
| ------------------ | ----------------------------- | ------------- | ---------------------- |
| monitoring.enabled | Enable or disable monitoring. | false         | 1.15.0                 |

### 12. Logging Configuration

| Name                                                    | Description                                                  | Default Value                     | Available from Version |
| ------------------------------------------------------- | ------------------------------------------------------------ | --------------------------------- | ---------------------- |
| logging.source                                          | Source for logging. Options: kubernetes, loki, elasticsearch | [kubernetes](#kubernetes-logging) | 1.10.0                 |
| [logging.lokiSettings](#loki-logging)                   | Settings for Loki logging backend.                           | {}                                | 1.10.0                 |
| [logging.elasticSearchSettings](#elasticsearch-logging) | Settings for Elasticsearch logging backend.                  | {}                                | 1.10.0                 |
| [logging.splunkSettings](#splunk-logging)               | Settings for Splunk logging backend.                         | {}                                | 1.15.0                 |

### 13. Java TrustStore Configuration

If you need to talk to services with self-signed certificates, you can enable the Java TrustStore and provide the
truststore file.
P.S. `truststore.jks` file should include the default public certificates in order to work with common public
resources (e.g. Github, Maven, Google). Do not create truststore.jks file with only self-signed certificates. Copy
Java's default truststore and add your custom certificates to it.

| Name                      | Description                                                       | Default Value         | Available from Version |
| ------------------------- | ----------------------------------------------------------------- | --------------------- | ---------------------- |
| javaTrustStore.enabled    | Enable Java TrustStore for handling self-signed certificates.     | false                 | 1.9.2                  |
| javaTrustStore.secretName | Name of the Kubernetes secret containing the truststore.jks file. | java-truststore       | 1.9.2                  |
| javaTrustStore.fileName   | Name of the truststore file.                                      | truststore.jks        | 1.9.2                  |
| javaTrustStore.password   | Password for the truststore.                                      | changeit              | 1.9.2                  |
| javaTrustStore.mountPath  | Mount path for the truststore file in the container.              | /etc/ssl/iomete-certs | 1.9.2                  |

### 14. Ingress Configuration

IOMETE Data Plane needs to know if the ingress is enabled and if HTTPS is enabled.

| Name                 | Description                   | Default Value | Available from Version |
| -------------------- | ----------------------------- | ------------- | ---------------------- |
| ingress.httpsEnabled | Enable HTTPS for the ingress. | true          | 1.9.2                  |

## Advanced Configuration Examples

### Database Password Secret

To use a Kubernetes secret for the database password:

```yaml
database:
  passwordSecret:
    name: your-db-creds-secret
    key: password
```

### Keycloak Admin Password Secret

To use a Kubernetes secret for the Keycloak admin password:

```yaml
keycloak:
  adminPasswordSecret:
    name: your-keycloak-creds-secret
    key: password
```

### MinIO Storage Settings

To configure MinIO storage settings:

```yaml
storage:
  minioSettings:
    endpoint: "http://minio.default.svc.cluster.local:9000"
    accessKey: "admin"
    secretKey: "password"
    # If secretKeySecret is set, the secretKey will be read from the secret
    secretKeySecret: { }
    #name: minio-creds-secret
    #key: secret-key
```

### Dell ECS Storage Settings

To configure Dell ECS storage settings:

```yaml
storage:
  dellEcsSettings:
    endpoint: "http://esc-host:ecs-port"
    accessKey: "admin"
    secretKey: "password"
    # If secretKeySecret is set, the secretKey will be read from the secret
    secretKeySecret: { }
    #name: ecs-creds-secret
    #key: secret-key
```

### Docker Image Pull Secrets

To configure Docker image pull secrets:

```yaml
docker:
  imagePullSecrets:
    - name: your-image-pull-secret
```

### Logging Configuration

To configure logging to different backends:

#### Kubernetes Logging

```yaml
logging:
  source: "kubernetes"
```

#### Loki Logging

```yaml
logging:
  source: "loki"
  lokiSettings:
    host: "loki-gateway"
    port: "80"
```

#### Elasticsearch Logging

```yaml
logging:
  source: "elasticsearch"
  elasticSearchSettings:
    host: "elasticsearch-master.efk.svc.cluster.local"
    port: "9200"
    apiKey: "elastic"
    indexPattern: "logstash-*"
```

#### Splunk Logging

```yaml
logging:
  source: "splunk"
  splunkSettings:
    endpoint: "https://splunk-enterprise-standalone-service:8089"
    token: "" # Bearer token created in Splunk Settings -> Tokens
    indexName: "main"
```

### 15. Services Configuration

#### Spark Operator

| Name                                     | Description                               | Default Value |
| ---------------------------------------- | ----------------------------------------- | ------------- |
| services.sparkOperator.metricAnnotations | Annotations for Spark Operator metrics    | See below     |
| services.sparkOperator.resources         | Resource configuration for Spark Operator | {}            |

The default metric annotations for the Spark Operator are:

```yaml
prometheus.io/scrape: "true"
prometheus.io/path: "/metrics"
prometheus.io/port: "metrics"
prometheus.io/scheme: "http"
prometheus.io/interval: "15s"
```