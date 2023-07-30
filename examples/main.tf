module "work_vm" {
  source = "github.com/danielkhen/virtual_machine_module"

  name                = "example-vm"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.example.name
  size                = "Standard_B2s"
  nic_name            = "example-nic"
  subnet_id           = azurerm_subnet.example.id
  os_type             = "Linux"

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

  admin_username = "adminuser"
  admin_password = "SecretPassword123!" #should be secret

  identity_type    = "SystemAssigned"
  role_assignments = local.role_assignments #View variable documentation

  log_analytics_enabled = local.log_analytics_enabled
  log_analytics_id      = module.hub_log_analytics.id
}
