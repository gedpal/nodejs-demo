terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}
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

  service_principal {
    client_id     = "NotNeededForExistingServiceConnection"
    client_secret = "NotNeededForExistingServiceConnection"
  }

  addon_profile {
    oms_agent {
      enabled = false
    }

    azure_policy {
      enabled = false
    }

    ingress_application_gateway {
      enabled = true
    }
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "aks_np" {
  name                = "aksnp"
  kubernetes_cluster = azurerm_kubernetes_cluster.aks_cluster.id
  vm_size             = "Standard_B1s"  # Smallest VM size
  node_count          = 1
  enable_auto_scaling = false
}
