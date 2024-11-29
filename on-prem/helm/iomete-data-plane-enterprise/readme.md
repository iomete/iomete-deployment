# IOMETE Data Plane Helm Enterprise Version

- **Helm Repository:** https://chartmuseum.iomete.com
- **Chart Name:** `iomete-data-plane-enterprise`
- **ArtifactHUB URL:** https://artifacthub.io/packages/helm/iomete/iomete-data-plane-enterprise

## Quick Start

```shell
# Add IOMETE helm repo
helm repo add iomete https://chartmuseum.iomete.com
helm repo update

# Deploy IOMETE Data Plane (to customize the installation see the Configuration section)
helm upgrade --install -n iomete-system iomete-data-plane \
  iomete/iomete-data-plane-enterprise --version {VERSION}
```

## Configuration

For more information about the available configurations, visit the [IOMETE Data Plane Enterprise](https://artifacthub.io/packages/helm/iomete/iomete-data-plane-enterprise) page on ArtifactHUB.  


## Advanced Configuration Examples

### Database Password Secret

To use a Kubernetes secret for the database password:

```yaml
database:
  passwordSecret:
    name: your-db-creds-secret
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

### Services Configuration

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