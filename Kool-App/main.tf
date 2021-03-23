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
resource "azurerm_resource_group" "kool-rg" {
  name     = "${var.env}-kool-rg"
  location = var.location-name
}

module "kool-vnet" {
  source              = "Azure/vnet/azurerm"
  vnet_name           = "${var.env}-kool-vnet"
  resource_group_name = azurerm_resource_group.fe-rg.name
  address_space       = ["10.0.0.0/23"]
  subnet_prefixes     = ["10.0.0.0/24", "10.0.1.0/24"]
  subnet_names        = ["${var.env}-app-subnet", "${var.env}-data-subnet"]
  tags = {
    environment = var.env
  }
}


# resource "azurerm_api_management" "example" {
#   name                = var.apim_name
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
#   publisher_name      = "My Company"
#   publisher_email     = "company@terraform.io"

#   sku_name = "Developer_1"
# }

# resource "azurerm_api_management_api" "example" {
#   name                = "example-api"
#   resource_group_name = azurerm_resource_group.example.name
#   api_management_name = azurerm_api_management.example.name
#   revision            = "1"
#   display_name        = var.api_name
#   path                = var.api_path
#   protocols           = ["https"]

#   import {
#     content_format = "swagger-link-json"
#     content_value  = var.api_url
#   }
# }