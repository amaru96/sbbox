resource "azurerm_resource_group" "resource_gp" {
  # "resource_gp" is the name of this resource, you can use it to call it for other resources
  name     = "Azure-Demo"
  location = "eastus"
  tags = {
    Owner = "Jim K"
  }
}

variable "prefix" {
  default = "MAP"
}

resource "azurerm_virtual_network" "main" {
  name = "${var.prefix}-network" #this will create a vnet called sl-network as it takes the "prefix" variable called above
  address_space = [
    "10.0.0.0/16",
  ]
  location            = "${azurerm_resource_group.resource_gp.location}" #This is calling the "resource_gp" above and using it's location and name
  resource_group_name = "${azurerm_resource_group.resource_gp.name}"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.resource_gp.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_subnet" "frontend" {
  name                 = "frontend"
  resource_group_name  = "${azurerm_resource_group.resource_gp.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix       = "10.0.3.0/24"
}

resource "azurerm_subnet" "backend" {
  name                 = "backend"
  resource_group_name  = "${azurerm_resource_group.resource_gp.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix       = "10.0.4.0/24"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic" #This will be called sl-nic as per the varibale declared above
  location            = "${azurerm_resource_group.resource_gp.location}"
  resource_group_name = "${azurerm_resource_group.resource_gp.name}"
  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.backend.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                = "${var.prefix}-vm" #VM name will be MAP-vm
  location            = "${azurerm_resource_group.resource_gp.location}"
  resource_group_name = "${azurerm_resource_group.resource_gp.name}"
  network_interface_ids = [
    "${azurerm_network_interface.main.id}",
  ]
  vm_size = "Standard_DS1_v2"
  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true
  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_windows_config {}
  tags = {
    environment = "staging"
  }
  /*
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  } */
}

resource "azurerm_virtual_network" "hub" {
  address_space = [
    "10.0.0.0/16",
  ]
  location            = "eastus"
  name                = "hubvnet"
  resource_group_name = "hub-rg"
}

resource "azurerm_resource_group" "hub" {
  location = "eastus"
  name     = "hub-rg"
}
