# IOMETE Data Plane Base

- **Helm Repository:** https://chartmuseum.iomete.com
- **Chart Name:** `iomete-data-plane-base`
- **Latest Version:** `1.13.0`

## Quick Start

```shell
# Add IOMETE helm repo
helm repo add iomete https://chartmuseum.iomete.com
helm repo update

# Deploy IOMETE Data Plane Base (to customize the installation see the Configuration section)
helm upgrade --install -n iomete-system data-plane-base \
  iomete/iomete-data-plane-base --version 1.11.0  
```

Here is the readme file for the provided values file:

## Configuration

### 1. Mutating Webhook Configuration

This section contains the configuration for the Mutating Webhook, which is used for dynamically modifying Kubernetes
resources during their creation or update.

| Name                                | Description                                | Default Value | Available from Version |
| ----------------------------------- | ------------------------------------------ | ------------- | ---------------------- |
| mutatingWebhookConfiguration.deploy | Deploy the mutating webhook configuration. | true          | 1.9.3                  |

### 2. Docker Configuration

This section contains the configuration for Docker, including image pull secrets which are used to authenticate with
private Docker registries.

| Name                    | Description                                   | Default Value | Available from Version |
| ----------------------- | --------------------------------------------- | ------------- | ---------------------- |
| docker.imagePullSecrets | List of image pull secrets for Docker images. | []            | 1.9.2                  |

## Advanced Configuration Examples

### Docker Image Pull Secrets

To configure Docker image pull secrets:

```yaml
docker:
  imagePullSecrets:
    - name: your-image-pull-secret
```