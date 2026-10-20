terraform {
  required_version = ">= 1.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.81"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.27"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.5"
    }
    jks = {
      source  = "paragor/jks"
      version = "~> 0.9"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
}

provider "kubernetes" {
  host                   = module.kubernetes_cluster.host
  client_certificate     = module.kubernetes_cluster.client_cert
  client_key             = module.kubernetes_cluster.client_key
  cluster_ca_certificate = module.kubernetes_cluster.cluster_ca_cert
}

provider "helm" {
  kubernetes = {
    host                   = module.kubernetes_cluster.host
    client_certificate     = module.kubernetes_cluster.client_cert
    client_key             = module.kubernetes_cluster.client_key
    cluster_ca_certificate = module.kubernetes_cluster.cluster_ca_cert
  }
}

# Creates the IOMETE database user from your machine, over the server's public endpoint.
provider "postgresql" {
  host      = module.postgresql_server.host
  port      = module.postgresql_server.port
  username  = module.postgresql_server.administrator_username
  password  = module.postgresql_server.administrator_password
  superuser = false
  sslmode   = "require"
}
