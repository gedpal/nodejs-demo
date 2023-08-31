terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
backend "azurerm" {
      resource_group_name  = "'Gediminas_Palskis_rg'"
      storage_account_name = "gedpalsa1"
      container_name       = "tf-state"
      key                  = "tf/terraform.tfstate"
  }
}
provider "azurerm" {
  skip_provider_registration = true
  features {}
}
provider "azuread" {
  version = "~>0.7"
}
data "azurerm_resource_group" "Gediminas_Palskis_rg" {
  name = "Gediminas_Palskis_rg"
}