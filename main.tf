# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.83.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

# Configure Service Principle
  subscription_id   = "c5f029c7-a268-4433-95d4-12eb70cd4cd0"
  tenant_id         = "ab70bfe3-44cc-4887-813f-f27addb46899"
  client_id         = "6ce3c813-57dc-4b64-9e26-6f6cb100327e"
  client_secret     = "RQO7Q~rf7~6RbGfkHAM6YsoR3AjnSOY7lq-Wt"
}

# Create a resource group
resource "azurerm_resource_group" "rg1" {
  name     = "jenkins-rg"
  location = var.location
}

# Create virtual network
resource "azurerm_virtual_network" "vmNetwork" {
    name                = "linvmsVnet"
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = azurerm_resource_group.rg1.name
}

# Create subnet
resource "azurerm_subnet" "vmSubnet" {
    name                 = "linvmsSubnet"
    resource_group_name  = azurerm_resource_group.rg1.name
    virtual_network_name = azurerm_virtual_network.vmNetwork.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "vmpublicip" {
    count = length(var.vmNames)
    name                         = "linvm${count.index}PublicIP"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rg1.name
    allocation_method            = "Static"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "vmnsg" {
    name                = "linvmsNetworkSecurityGroup"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg1.name

    security_rule {
        name                       = "AllowAll"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# Create network interface
resource "azurerm_network_interface" "vmnic" {
    count = length(var.vmNames)
    name                      = "linvm${count.index}NIC"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rg1.name

    ip_configuration {
        name                          = "linvmsNicConfiguration"
        subnet_id                     = azurerm_subnet.vmSubnet.id
        private_ip_address_allocation = "Static"
        public_ip_address_id          = azurerm_public_ip.vmpublicip[count.index].id
        private_ip_address            ="10.0.1.${count.index+5}"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "netConnection" {
    count = length(var.vmNames)
    network_interface_id      = azurerm_network_interface.vmnic[count.index].id
    network_security_group_id = azurerm_network_security_group.vmnsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "linvm" {
    count = length(var.vmNames)
    name                  = var.vmNames[count.index]
    location              = var.location
    resource_group_name   = azurerm_resource_group.rg1.name
    network_interface_ids = [azurerm_network_interface.vmnic[count.index].id]
    size                  = "Standard_D2s_v3"
    admin_username = "vmadmin"
    admin_password = var.userAdminKey
    disable_password_authentication = false

    admin_ssh_key {
    username   = "vmadmin"
    public_key = file("~/.ssh/id_rsa.pub")
    }

    source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest" 
    }

    os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite" 
    }

    provisioner "remote-exec" {
    inline = [
        "mkdir /home/vmadmin/scripts"
        ]

    connection {
        type     = "ssh"
        user     = "vmadmin"
        password = "Password123!"
        host     = self.public_ip_address
        private_key = "${file("~/.ssh/id_rsa")}"
        agent = true
        }
    }

    provisioner "file" {
    source      = "~/Documents/devopsProj1/jenkins-infra-setup/${var.vmScripts[count.index]}"
    destination = "/home/vmadmin/scripts/${var.vmScripts[count.index]}"

    connection {
        type     = "ssh"
        user     = "vmadmin"
        password = "Password123!"
        host     = self.public_ip_address
        private_key = "${file("~/.ssh/id_rsa")}"
        agent = true
        }
    }

    provisioner "remote-exec" {
    inline = [
        "chmod +x ${var.vmScripts[count.index]}",
        "./${var.vmScripts[count.index]}"
        ]

    connection {
        type     = "ssh"
        user     = "vmadmin"
        password = "Password123!"
        host     = self.public_ip_address
        private_key = "${file("~/.ssh/id_rsa")}"
        agent = true
        }
    }
}


