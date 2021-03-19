resource "azurerm_resource_group" "fw-rg" {
  name     = "fw-rg"
  location = "eastus"

}

resource "azurerm_virtual_network" "fw-rg" {
  name                = "fw-vnet"
  address_space       = ["10.0.0.0/23"]
  location            = azurerm_resource_group.fw-rg.location
  resource_group_name = azurerm_resource_group.fw-rg.name
}

resource "azurerm_subnet" "fw-rg-01" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.fw-rg.name
  virtual_network_name = azurerm_virtual_network.fw-rg.name
  address_prefixes      = ["10.0.0.0/26"]
}

resource "azurerm_subnet" "fw-rg-02" {
  name                 = "jbox-subnet"
  resource_group_name  = azurerm_resource_group.fw-rg.name
  virtual_network_name = azurerm_virtual_network.fw-rg.name
  address_prefixes      = ["10.0.0.64/26"]
}

resource "azurerm_public_ip" "fw-rg" {
  name                = "pub-ip01"
  location            = azurerm_resource_group.fw-rg.location
  resource_group_name = azurerm_resource_group.fw-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "fw-rg" {
  name                = "fw-01"
  location            = azurerm_resource_group.fw-rg.location
  resource_group_name = azurerm_resource_group.fw-rg.name
  ip_configuration {
    name                 = "fwip-config"
    subnet_id            = azurerm_subnet.fw-rg-01.id
    public_ip_address_id = azurerm_public_ip.fw-rg.id
  }
}