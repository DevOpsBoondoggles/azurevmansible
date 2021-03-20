terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.52.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
    name = var.nameofall
    location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  address_space = [ "10.0.0.0/16" ]
  resource_group_name = azurerm_resource_group.rg.name
  name = var.nameofall
  location = var.location
}

resource "azurerm_subnet" "sub" {
  name = var.nameofall
  address_prefixes = [ "10.0.1.0/24" ]
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_network_interface" "nic" {
  resource_group_name = azurerm_resource_group.rg.name
  name = var.nameofall
  location = var.location
  ip_configuration {
    name = var.nameofall
    public_ip_address_id = azurerm_public_ip.pip.id
    private_ip_address_allocation = "Dynamic"
    primary = true
    subnet_id = azurerm_subnet.sub.id
  }
}

resource "azurerm_public_ip" "pip" {
  resource_group_name = azurerm_resource_group.rg.name
  name = var.nameofall
  location = var.location
  allocation_method = "Dynamic"
}


resource "azurerm_virtual_machine" "vm" {
  resource_group_name = azurerm_resource_group.rg.name
  name = var.nameofall
  location = var.location
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size = "Standard_DS2_v2"
  os_profile_windows_config {
    
  }
  
  os_profile {
    computer_name  = "ansiblevm"
    admin_username = "adminuser12"
    admin_password = "P@$$word1234!"
  }


  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
    
  storage_image_reference {
    id = "/subscriptions/093f11e6-c3b7-42cf-aa06-77ce8e447b77/resourceGroups/MYPACKERGROUP/providers/Microsoft.Compute/images/ansibleenabled"
  }
}


