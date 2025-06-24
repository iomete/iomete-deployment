output "kube_config" {
  description = "Raw kubeconfig to be used with kubectl"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "host" {
  description = "The Kubernetes cluster server host"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].host
  sensitive   = true
}

output "client_cert" {
  description = "Public certificate used by clients to authenticate to the Kubernetes cluster"
  value = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  sensitive = true
}

output "client_key" {
  description = "Private key used by clients to authenticate to the Kubernetes cluster"
  value = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  sensitive = true
}

output "cluster_ca_cert" {
  description = "Public CA certificate used as the root of trust for the Kubernetes cluster"
  value = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
  sensitive = true
}