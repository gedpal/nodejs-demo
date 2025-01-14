# Locals block for hardcoded names
data "azurerm_resource_group" "rg" {
  name = "Gediminas_Palskis_rg"
}
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.test.name}-beap"
  backend_address_pool_name2      = "${azurerm_virtual_network.test.name}-beap2"
  frontend_port_name             = "${azurerm_virtual_network.test.name}-feport"
  frontend_port_name2             = "${azurerm_virtual_network.test.name}-feport2"
  frontend_ip_configuration_name = "${azurerm_virtual_network.test.name}-feip"
  frontend_ip_configuration_name2 = "${azurerm_virtual_network.test.name}-feip2"
  http_setting_name              = "${azurerm_virtual_network.test.name}-be-htst"
  http_setting_name2              = "${azurerm_virtual_network.test.name}-be-htst2"
  listener_name                  = "${azurerm_virtual_network.test.name}-httplstn"
  listener_name2                  = "${azurerm_virtual_network.test.name}-httplstn2"
  request_routing_rule_name      = "${azurerm_virtual_network.test.name}-rqrt"
  request_routing_rule_name2      = "${azurerm_virtual_network.test.name}-rqrt2"
  app_gateway_subnet_name        = "appgwsubnet"
}

# User Assigned Identities 
resource "azurerm_user_assigned_identity" "testIdentity" {
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  name = "gpaidentity1"
}

resource "azurerm_virtual_network" "test" {
  name                = var.virtual_network_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = [var.virtual_network_address_prefix]

  subnet {
    name           = var.aks_subnet_name
    address_prefix = var.aks_subnet_address_prefix
  }

  subnet {
    name           = "appgwsubnet"
    address_prefix = var.app_gateway_subnet_address_prefix
  }
}
data "azurerm_subnet" "kubesubnet" {
  name                 = var.aks_subnet_name
  virtual_network_name = azurerm_virtual_network.test.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}
data "azurerm_subnet" "appgwsubnet" {
  name                 = "appgwsubnet"
  virtual_network_name = azurerm_virtual_network.test.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

# Public Ip 
resource "azurerm_public_ip" "test" {
  name                = "publicIp1"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
/* resource "azurerm_public_ip" "test2" {
  name                = "publicIp2"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
} */

resource "azurerm_application_gateway" "network" {
  name                = var.app_gateway_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  sku {
    name     = var.app_gateway_sku
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = data.azurerm_subnet.appgwsubnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_port {
    name = "httpsPort"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.test.id
  }

/*   frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name2
    public_ip_address_id = azurerm_public_ip.test2.id
  } */

  backend_address_pool {
    name = local.backend_address_pool_name
    ip_addresses = ["192.168.0.26", "192.168.0.7", "192.168.0.9"]
  }

  backend_address_pool {
    name = local.backend_address_pool_name2
    ip_addresses = ["192.168.0.13", "192.168.0.19", "192.168.0.20"]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 3000
    protocol              = "Http"
    request_timeout       = 1
  }

  backend_http_settings {
    name                  = local.http_setting_name2
    cookie_based_affinity = "Disabled"
    port                  = 3000
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_names = [ "app1.grit.lt"]
  }
  http_listener {
    name                           = local.listener_name2
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_names = [ "app2.grit.lt"]
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 1
  }
  request_routing_rule {
    name                       = local.request_routing_rule_name2
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name2
    backend_address_pool_name  = local.backend_address_pool_name2
    backend_http_settings_name = local.http_setting_name2
    priority                   = 2
  }
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.aks_cluster_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = var.aks_dns_prefix
  http_application_routing_enabled = false
  linux_profile {
    admin_username = var.vm_username
    ssh_key {
      key_data = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
    }
  }
  default_node_pool {
    name       = "agentpool"
    node_count = var.aks_agent_count
#    vm_size    = "Standard_B2als_v2" <- hit limits :)
    vm_size         = var.aks_agent_vm_size
    os_disk_size_gb = var.aks_agent_os_disk_size
    vnet_subnet_id  = data.azurerm_subnet.kubesubnet.id
  }

  identity {
    type = "SystemAssigned"
  }
  tags = {
    Environment = "Dev"
  }
  network_profile {
  network_plugin     = "azure"
  dns_service_ip     = var.aks_dns_service_ip
  docker_bridge_cidr = var.aks_docker_bridge_cidr
  service_cidr       = var.aks_service_cidr
  }
}

resource "azurerm_container_registry" "acr1" {
  name                     = var.acr_name
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  sku                      = "Basic"
  admin_enabled            = false
  identity {
    type = "SystemAssigned"
  }
}
  resource "azurerm_role_assignment" "roleassign" {
  principal_id                     =  azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr1.id
  skip_service_principal_aad_check = true
} 
