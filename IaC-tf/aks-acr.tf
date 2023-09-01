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
resource "azurerm_container_registry" "gpatfacr1" {
  name                     = "gpatfacr1"
  resource_group_name      = data.azurerm_resource_group.Gediminas_Palskis_rg.name
  location                 = data.azurerm_resource_group.Gediminas_Palskis_rg.location
  sku                      = "Basic"
  admin_enabled            = false
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_role_assignment" "roleassign" {
  principal_id                     =  azurerm_kubernetes_cluster.gpatfaks1.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.gpatfacr1.id
  skip_service_principal_aad_check = true
}