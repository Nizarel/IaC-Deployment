resource "azurerm_virtual_network_peering" "fw-be" {
  name                      = "peer-fw-be"
  resource_group_name       = azurerm_resource_group.fw-rg.name
  virtual_network_name      = azurerm_virtual_network.fw-rg.name
  remote_virtual_network_id = azurerm_virtual_network.be-rg.id
}

resource "azurerm_virtual_network_peering" "be-fw" {
  name                      = "peer-be-fw"
  resource_group_name       = azurerm_resource_group.be-rg.name
  virtual_network_name      = azurerm_virtual_network.be-rg.name
  remote_virtual_network_id = azurerm_virtual_network.fw-rg.id
}

resource "azurerm_firewall_nat_rule_collection" "fw-rg" {
  name                = "nat-rules"
  azure_firewall_name = azurerm_firewall.fw-rg.name
  resource_group_name = azurerm_resource_group.fw-rg.name
  priority            = 100
  action              = "Dnat"

  rule {
    name                  = "webrule"
    source_addresses      = ["*"]
    destination_ports     = ["80"]
    destination_addresses = [azurerm_public_ip.fw-rg.ip_address]
    translated_port       = 80
    translated_address    = azurerm_network_interface.be-rg.private_ip_address
    protocols             = ["TCP"]
  }

  rule {
    name                  = "jboxrule"
    source_addresses      = ["*"]
    destination_ports     = ["3389"]
    destination_addresses = [azurerm_public_ip.fw-rg.ip_address]
    translated_port       = 3389
    translated_address    = azurerm_network_interface.jbox-rg.private_ip_address
    protocols             = ["TCP"]
  }

}
