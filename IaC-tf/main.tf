required_providers {
  azurerm = {
    source  = "hashicorp/azurerm"
    version = ">=3.0"
  }
}
resource "azurerm_resource_group" "aks_rg" {
  name     = "Gediminas_Palskis_rg"
  location = "West Europe"
}
