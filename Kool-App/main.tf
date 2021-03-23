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
  tags = {
    environment = var.env
  }
}

module "kool-vnet" {
  source              = "Azure/vnet/azurerm"
  vnet_name           = "${var.env}-kool-vnet"
  resource_group_name = azurerm_resource_group.kool-rg.name
  address_space       = ["10.0.0.0/23"]
  subnet_prefixes     = ["10.0.0.0/24", "10.0.1.0/24"]
  subnet_names        = ["${var.env}-app-subnet", "${var.env}-data-subnet"]
  tags = {
    environment = var.env
  }
  depends_on = [azurerm_resource_group.kool-rg]
}

resource "azurerm_storage_account" "sa" {
  //name                      = "${var.env}-kool-sg"
  name = "${var.env}koolsg"
  resource_group_name       = azurerm_resource_group.kool-rg.name
  location                  = azurerm_resource_group.kool-rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  allow_blob_public_access  = false
  enable_https_traffic_only = true

    tags = {
    environment = var.env
  }
}

resource "azurerm_app_service_plan" "asp" {
  name                = "${var.env}-kool-applan"
  resource_group_name = azurerm_resource_group.kool-rg.name
  location            = azurerm_resource_group.kool-rg.location
  kind                = "functionapp"
  reserved            = true


# Add SKU Env Condition!!
  sku {
    size = var.function-size
    tier = var.function-tier
  }
    tags = {
    environment = var.env
  }
}

resource "azurerm_application_insights" "appinsights" {
  name                = "${var.env}-insight"
  resource_group_name = azurerm_resource_group.kool-rg.name
  location            = azurerm_resource_group.kool-rg.location
  application_type    = "web"

    tags = {
    environment = var.env
  }
}

resource "azurerm_function_app" "function" {
  name                       = "${var.env}-kool-func"
  resource_group_name        = azurerm_resource_group.kool-rg.name
  location                   = azurerm_resource_group.kool-rg.location
  app_service_plan_id        = azurerm_app_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  https_only                 = true
  os_type                    = "linux"
  version                    = "~3"

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "custom"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.appinsights.instrumentation_key
  }
  depends_on = [ azurerm_app_service_plan.asp, azurerm_application_insights.appinsights, azurerm_storage_account.sa] 
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