terraform {
  backend "azurerm" {
    # settings to store terraform state in azure
    resource_group_name  = var.terraform_state_resource_group_name
    storage_account_name = var.terraform_state_storage_account_name
    container_name       = var.terraform_state_container_name
    key                  = var.terraform_state_key
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source  = "hashicorp/helm"
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
