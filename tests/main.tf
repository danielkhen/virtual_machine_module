locals {
  location            = "westeurope"
  resource_group_name = "dtf-virtual-machine-test"
}

resource "azurerm_resource_group" "test_rg" {
  name     = local.resource_group_name
  location = local.location

  lifecycle {
    ignore_changes = [tags["CreationDateTime"], tags["Environment"]]
  }
}

locals {
  vnet_name          = "vnet"
  vnet_address_space = ["10.0.0.0/16"]
  vnet_dns_servers   = ["11.0.0.0"]

  vnet_subnets = [
    {
      name           = "VMSubnet"
      address_prefix = "10.0.0.0/24"
    }
  ]
}

module "vnet" {
  source = "../../virtual_network"

  name                = local.vnet_name
  location            = local.location
  resource_group_name = azurerm_resource_group.test_rg.name
  address_space       = local.vnet_address_space
  subnets             = local.vnet_subnets
}

locals {
  vm_name                            = "test-vm"
  vm_size                            = "Standard_B2s"
  nic_name                           = "test-nic"
  vm_os_type                         = "Linux"
  vm_admin_username                  = "daniel"
  vm_disable_password_authentication = true
  vm_public_ssh_key                  = file("./id_rsa.pub")

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

module "vm" {
  source = "../"

  name                            = local.vm_name
  location                        = local.location
  resource_group_name             = azurerm_resource_group.test_rg.name
  nic_name                        = local.nic_name
  os_disk                         = local.os_disk
  os_type                         = local.vm_os_type
  size                            = local.vm_size
  subnet_id                       = module.vnet.subnet_ids["VMSubnet"]
  source_image_reference          = local.source_image_reference
  disable_password_authentication = local.vm_disable_password_authentication
  admin_username                  = local.vm_admin_username
  admin_public_ssh_key            = local.vm_public_ssh_key
}