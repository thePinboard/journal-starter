output "registry_url" {
  value = azurerm_container_registry.acr.login_server
}

output "kubeconfig" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}
