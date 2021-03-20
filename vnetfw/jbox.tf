# jbox-rg
# jbox-nic
# jbox-nsg
# jbox-VM01
# nsg rule to allow RDP from anywhere to the jumpbox

resource "azurerm_resource_group" "jbox-rg" {
  name     = var.jb-rg-name
  location = var.location-name

}

resource "azurerm_network_interface" "jbox-rg" {
  name                = "${var.jb-vm-name}-nic"
  location            = azurerm_resource_group.jbox-rg.location
  resource_group_name = azurerm_resource_group.jbox-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.fw-rg-02.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "jbox-rg" {
  name                = "${var.jb-vm-name}-nsg"
  location            = azurerm_resource_group.jbox-rg.location
  resource_group_name = azurerm_resource_group.jbox-rg.name

  security_rule {
    name                       = "rdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "${azurerm_network_interface.jbox-rg.private_ip_address}/32"
    
  }

}

resource "azurerm_network_interface_security_group_association" "jbox-rg" {
  network_interface_id      = azurerm_network_interface.jbox-rg.id
  network_security_group_id = azurerm_network_security_group.jbox-rg.id
}

resource "azurerm_windows_virtual_machine" "jbox-rg" {
  name                  = "${var.jb-vm-name}-vm01"
  resource_group_name   = azurerm_resource_group.jbox-rg.name
  location              = azurerm_resource_group.jbox-rg.location
  size                  = "Standard_DS1_v2"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.jbox-rg.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

}