provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aks_rg" {
  name     = "Gediminas_Palskis_rg"
  location = "West Europe"
}
