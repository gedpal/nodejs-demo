terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}
provider "azurerm" {
  skip_provider_registration = true
  features {}
}
data "azurerm_resource_group" "Gediminas_Palskis_rg" {
  name = "Gediminas_Palskis_rg"
}