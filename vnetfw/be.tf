	# - Set BE Resource Group
	# - Set Web Vnet
	# 	○ Web Subnet
	# - Web-Interface
	# - Web-NSG
  #    Web-VM01

resource "azurerm_resource_group" "be-rg" {
  name     = "be-rg"
  location = "eastus"

}

resource "azurerm_virtual_network" "be-rg" {
  name                = "web-vnet"
  address_space       = ["10.0.2.0/23"]
  location            = azurerm_resource_group.be-rg.location
  resource_group_name = azurerm_resource_group.be-rg.name
}

resource "azurerm_subnet" "be-rg" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.be-rg.name
  virtual_network_name = azurerm_virtual_network.be-rg.name
  address_prefixes      = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "be-rg" {
  name                = "web-nic"
  location            = azurerm_resource_group.be-rg.location
  resource_group_name = azurerm_resource_group.be-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.be-rg.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "be-rg" {
  name                = "web-nsg"
  location            = azurerm_resource_group.be-rg.location
  resource_group_name = azurerm_resource_group.be-rg.name

  security_rule {
    name                       = "web"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = azurerm_network_interface.be-rg.private_ip_address/32
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface_security_group_association" "be-rg" {
  network_interface_id      = azurerm_network_interface.be-rg.id
  network_security_group_id = azurerm_network_security_group.be-rg.id
}

resource "azurerm_virtual_machine" "be-rg" {
  name                  = "Web-vm01"
  location              = azurerm_resource_group.be-rg.location
  resource_group_name   = azurerm_resource_group.be-rg.name
  network_interface_ids = [azurerm_network_interface.be-rg.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "web-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = azurerm_virtual_machine.be-rg.name
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}