# IOMETE Data Plane Helm - AWS Community Version

- **Helm Repository:** https://chartmuseum.iomete.com
- **Chart Name:** `iomete-data-plane-community-aws`
- **Latest Version:** `1.9.4`

## Quick Start

```shell
# Add IOMETE helm repo
helm repo add iomete https://chartmuseum.iomete.com
helm repo update


# Deploy IOMETE Data Plane (to customize the installation see the Configuration section)
helm upgrade --install -n iomete-system iomete-data-plane \
  iomete/iomete-data-plane-community-aws --version 1.9 \
  --set ingress.httpsEnabled=false
```

## Configuration

### 1. General Configuration

| Name | Description                         | Default Value    |
|------|-------------------------------------|------------------|
| name | The unique name for the data plane. | iomete-community |

### 2. Admin User

This is the user that will be created for the data plane admin. Additional users can be created later through the IOMETE
Data Plane UI.
In most cases, the default values for the admin user are sufficient. If you need you can change first name, last name,
email, and temporary password.
The `username` and `temporaryPassword` will be used for the first login.

| Name                        | Description                                  | Default Value     |
|-----------------------------|----------------------------------------------|-------------------|
| adminUser.username          | Username for the data plane admin user.      | admin             |
| adminUser.email             | Email address for the data plane admin user. | admin@example.com |
| adminUser.firstName         | First name of the admin user.                | Admin             |
| adminUser.lastName          | Last name of the admin user.                 | Admin             |
| adminUser.temporaryPassword | Temporary password for first login.          | admin             |

### 3. Database Configuration

This section contains the configuration for the database used by the IOMETE Data Plane. The default values are set for a
PostgreSQL database, but you can adjust them to match your database configuration.

| Name                    | Description                                                                                                           | Default Value |
|-------------------------|-----------------------------------------------------------------------------------------------------------------------|---------------|
| database.type           | Type of the database supported.                                                                                       | postgresql    |
| database.host           | Hostname for the database.                                                                                            | postgresql    |
| database.port           | Port on which the database server is listening.                                                                       | 5432          |
| database.user           | Username to connect to the database.                                                                                  | iomete_user   |
| database.password       | Password to connect to the database.                                                                                  | iomete_pass   |
| database.passwordSecret | Name of the Kubernetes secret containing the database password. If this is set, the `password` field will be ignored. |               |
| database.prefix         | Prefix to be added to all IOMETE databases. This is useful when multiple IOMETE instances share the same database.    | iomete_       |
| database.ssl.enabled    | Enable SSL for database connections.                                                                                  | false         |
| database.ssl.mode       | SSL mode for database connections.                                                                                    | disable       |

#### Database Admin Credentials

When this section is provided, IOMETE will create all the necessary databases and users for the IOMETE Data Plane.
Remove this section if you want to handle the database setup manually.

| Name                                     | Description                                                                                                                 | Default Value |
|------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------|---------------|
| database.adminCredentials.user           | A database user which has rights to create databases, users, and grant privileges.                                          | postgres      |
| database.adminCredentials.password       | Password for the database admin user.                                                                                       |               |
| database.adminCredentials.passwordSecret | Name of the Kubernetes secret containing the database admin password. If this is set, the `password` field will be ignored. |               |

### 4. Spark Configuration

| Name           | Description                               | Default Value |
|----------------|-------------------------------------------|---------------|
| spark.logLevel | Default log level for Spark applications. | warn          |

### 5. Keycloak Configuration

Keycloak is the identity provider used for authentication, user management in the IOMETE Data Plane.

| Name                         | Description                                                                                                                      | Default Value             |
|------------------------------|----------------------------------------------------------------------------------------------------------------------------------|---------------------------|
| keycloak.enabled             | Enable or disable Keycloak authentication.                                                                                       | true                      |
| keycloak.adminUser           | Username for Keycloak admin.                                                                                                     | kc_admin                  |
| keycloak.adminPassword       | Password for Keycloak admin.                                                                                                     | Admin_123                 |
| keycloak.adminPasswordSecret | Name of the Kubernetes secret containing the Keycloak admin password. If this is set, the `adminPassword` field will be ignored. |                           |
| keycloak.endpoint            | Endpoint URL for Keycloak service. Only change this if you are using a custom Keycloak instance.                                 | http://keycloak-http/auth |

### 6. Cluster and Docker Configuration

| Name                | Description                                                                                              | Default Value |
|---------------------|----------------------------------------------------------------------------------------------------------|---------------|
| clusterDomain       | Kubernetes cluster domain.                                                                               | cluster.local |
| docker.repo         | Docker repository for pulling images. If you want to use a custom repository, you can change this value. | iomete        |
| docker.appVersion   | Version of the application Docker images                                                                 | 1.9.4         |
| docker.sparkVersion | Spark version for the Docker image.                                                                      | 3.5.1         |

### 7. Jupyter Gateway Configuration

Jupyter Gateway is a service that provides a Remote jupiter notebook kernel for Spark and Scala.

| Name                   | Description                                   | Default Value                      |
|------------------------|-----------------------------------------------|------------------------------------|
| jupyterGateway.kernels | List of kernels available in Jupyter Gateway. | pyspark_kernel, spark_scala_kernel |

### 8. Java TrustStore Configuration

If you need to talk to services with self-signed certificates, you can enable the Java TrustStore and provide the
truststore file.

| Name                      | Description                                                       | Default Value         |
|---------------------------|-------------------------------------------------------------------|-----------------------|
| javaTrustStore.enabled    | Enable Java TrustStore for handling self-signed certificates.     | false                 |
| javaTrustStore.secretName | Name of the Kubernetes secret containing the truststore.jks file. | java-truststore       |
| javaTrustStore.fileName   | Name of the truststore file.                                      | truststore.jks        |
| javaTrustStore.password   | Password for the truststore.                                      | changeit              |
| javaTrustStore.mountPath  | Mount path for the truststore file in the container.              | /etc/ssl/iomete-certs |

### 9. Ingress Configuration

IOMETE Data Plane needs to know if the ingress is enabled and if HTTPS is enabled.

| Name                 | Description                   | Default Value |
|----------------------|-------------------------------|---------------|
| ingress.httpsEnabled | Enable HTTPS for the ingress. | true          |