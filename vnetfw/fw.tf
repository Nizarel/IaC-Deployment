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


resource "azurerm_resource_group" "fw-rg" {
  name     = var.fw-rg-name
  location = var.location-name

}

resource "azurerm_virtual_network" "fw-rg" {
  name                = var.fw-vnet-name
  address_space       = ["10.0.0.0/23"]
  location            = azurerm_resource_group.fw-rg.location
  resource_group_name = azurerm_resource_group.fw-rg.name
}

resource "azurerm_subnet" "fw-rg-01" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.fw-rg.name
  virtual_network_name = azurerm_virtual_network.fw-rg.name
  address_prefixes     = ["10.0.0.0/26"]
}

resource "azurerm_subnet" "fw-rg-02" {
  name                 = var.jb-sub-name
  resource_group_name  = azurerm_resource_group.fw-rg.name
  virtual_network_name = azurerm_virtual_network.fw-rg.name
  address_prefixes     = ["10.0.0.64/26"]
}

resource "azurerm_public_ip" "fw-rg" {
  name                = var.pip-name
  location            = azurerm_resource_group.fw-rg.location
  resource_group_name = azurerm_resource_group.fw-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "fw-rg" {
  name                = var.fw-name
  location            = azurerm_resource_group.fw-rg.location
  resource_group_name = azurerm_resource_group.fw-rg.name
  ip_configuration {
    name                 = "fwip-config"
    subnet_id            = azurerm_subnet.fw-rg-01.id
    public_ip_address_id = azurerm_public_ip.fw-rg.id
  }
}