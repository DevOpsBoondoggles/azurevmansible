terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.52.0"
    }
  }
  # backend "azurerm" { }  #this line needs uncommented if using Azure backend via the charles zipp extension. 
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


resource "azurerm_windows_virtual_machine" "vm" {
  resource_group_name = azurerm_resource_group.rg.name
  name = var.nameofall
  location = var.location
  network_interface_ids = [azurerm_network_interface.nic.id]
  size = "Standard_D2_v3"
  os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  admin_username = "adminuser12"
  admin_password = "P@$$word1234!"
  computer_name = "ansiblevm"

  provision_vm_agent = true
  allow_extension_operations = true
}


resource "azurerm_virtual_machine_extension" "vmext" {
  name                 = azurerm_windows_virtual_machine.vm.name
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1",
        "fileUris": ["https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"]

    }
SETTINGS

}
