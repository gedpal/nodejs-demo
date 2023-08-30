resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "gpatfaks1"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "gpatfaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"  # Smallest VM size
  }

  identity {
    type = "SystemAssigned"
  }
  tags = {
    Environment = "Dev"
  }
}
output "client_certificate" {
  value     = azurerm_kubernetes_cluster.example.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw

  sensitive = true
}