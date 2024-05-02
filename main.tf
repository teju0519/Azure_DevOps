terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example_rg" {
  name     = "${var.prefix}-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "example_vnet" {
  name                = "${var.prefix}-network"
  resource_group_name = azurerm_resource_group.example_rg.name
  location            = azurerm_resource_group.example_rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example_subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.example_rg.name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "example_pip" {
  name = "acceptancetestpublicip1"
  resource_group_name = azurerm_resource_group.example_rg.name
  location = azurerm_resource_group.example_rg.location
  allocation_method = "Static"
}

resource "azurerm_network_interface" "example_ni" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name

  ip_configuration {
    name                          = "testipc"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.example_subnet.id
    public_ip_address_id = azurerm_public_ip.example_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "example_vm" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.example_rg.location
  resource_group_name   = azurerm_resource_group.example_rg.name
  admin_username = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.example_ni.id,
  ]
  size               = "Standard_DS1_v2"
  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  os_disk {
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  tags = {
    environment = "staging"
  }
}


provider "aws" {
  region = "us-east-1"
}
  resource "azurerm_storage_account" "example_sa" {
  name = "${var.prefix}sa"
  resource_group_name = azurerm_resource_group.example_rg.name
  location = azurerm_resource_group.example_rg.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example_sc" {
  name = "content"
  storage_account_name = azurerm_storage_account.example_sa.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "example_blob" {
  name = "mycontent"
  storage_account_name = azurerm_storage_account.example_sa.name
  storage_container_name = azurerm_storage_container.example_sc.name
  type = "Block"
}
