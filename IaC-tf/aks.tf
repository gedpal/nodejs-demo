resource "azurerm_kubernetes_cluster" "gpatfaks1" {
  name                = "gpatfaks1"
  location            = data.azurerm_resource_group.Gediminas_Palskis_rg.location
  resource_group_name = data.azurerm_resource_group.Gediminas_Palskis_rg.name
  dns_prefix          = "gpatfaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
#    vm_size    = "Standard_B2als_v2" <- hit limits :)
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
  tags = {
    Environment = "Dev"
  }
}
output "client_certificate" {
  value     = azurerm_kubernetes_cluster.gpatfaks1.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.gpatfaks1.kube_config_raw

  sensitive = true
}