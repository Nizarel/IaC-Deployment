terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "VodafDev" {
  name     = "VodafDev-rg"
  location = "eastus"
}

# Create a virtual network within the resource group
resource "azurerm_api_management" "VodafDev" {
  name                = "VodafDev-apim"
  location            = azurerm_resource_group.VodafDev.location
  resource_group_name = azurerm_resource_group.VodafDev.name
  publisher_name      = "Vodafone"
  publisher_email     = "vodafone@terraform.io"

  sku_name = "Developer_1"
}
resource "azurerm_api_management_api" "VodafDev" {
  name                = "example-api"
  resource_group_name = azurerm_resource_group.VodafDev.name
  api_management_name = azurerm_api_management.VodafDev.name
  revision            = "1"
  display_name        = "POI API"
  path                = "poi"
  protocols           = ["https"]

  import {
    #content_format = "swagger-link-json"
    content_value  = "http://kub.nizare.biz/api"
  }
}