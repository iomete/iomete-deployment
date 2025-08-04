terraform {
  backend "azurerm" {
    # settings to store terraform state in azure
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "iomete"
    container_name       = "tfstate"
    key                  = "iomete/kubernetes.tfstate"
  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
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

provider "kubectl" {
  host                   = module.kubernetes_cluster.host
  client_certificate     = module.kubernetes_cluster.client_cert
  client_key             = module.kubernetes_cluster.client_key
  cluster_ca_certificate = module.kubernetes_cluster.cluster_ca_cert
  load_config_file       = false
}
