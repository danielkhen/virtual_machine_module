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
  activity_log_analytics_name           = "activity-monitor-log-workspace"
  activity_log_analytics_resource_group = "dor-hub-n-spoke"
}

data "azurerm_log_analytics_workspace" "activity" {
  name                = local.activity_log_analytics_name
  resource_group_name = local.activity_log_analytics_resource_group
}

locals {
  vm_name                            = "test-vm"
  vm_size                            = "Standard_B2s"
  vm_os_type                         = "Linux"
  vm_admin_username                  = "daniel"
  vm_disable_password_authentication = true
  vm_public_ssh_key                  = file("./id_rsa.pub")
  vm_public_ip_enabled               = true
  vm_public_ip_name                  = "test-vm-ip"

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  disks = [
    {
      name                 = "disk1"
      create_option        = "Empty"
      storage_account_type = "Standard_LRS"
      caching              = "ReadWrite"
      disk_size_gb         = 3
    },
    {
      name                 = "disk2"
      create_option        = "Empty"
      storage_account_type = "Standard_LRS"
      caching              = "ReadOnly"
      disk_size_gb         = 5
    }
  ]

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
  os_disk                         = local.os_disk
  os_type                         = local.vm_os_type
  size                            = local.vm_size
  subnet_id                       = module.vnet.subnet_ids["VMSubnet"]
  source_image_reference          = local.source_image_reference
  disable_password_authentication = local.vm_disable_password_authentication
  admin_username                  = local.vm_admin_username
  admin_public_ssh_key            = local.vm_public_ssh_key
  disks                           = local.disks
  log_analytics_id                = data.azurerm_log_analytics_workspace.activity.id
  public_ip_enabled               = local.vm_public_ip_enabled
  public_ip_name                  = local.vm_public_ip_name
}