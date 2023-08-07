locals {
  ip_allocation_method         = "Static"
  private_ip_allocation_method = "Dynamic"
  is_windows                   = var.os_type == "Windows"
}

locals {
  ip_configuration_name = "default"
  vms_map = { for index in range(var.vm_count) : "${var.name}-${index}" => {
    name     = var.vm_count == 1 ? var.name : "${var.name}-${index}"
    nic_name = var.vm_count == 1 ? "${var.name}-nic" : "${var.name}-${index}-nic"
  } }
}

resource "azurerm_network_interface" "nics" {
  for_each = local.vms_map

  name                = each.value.nic_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = local.ip_configuration_name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = local.private_ip_allocation_method
  }

  lifecycle {
    ignore_changes = [tags["CreationDateTime"], tags["Environment"]]
  }
}

resource "azurerm_windows_virtual_machine" "vms" {
  for_each = local.is_windows ? local.vms_map : {}

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.size

  network_interface_ids = [
    azurerm_network_interface.nics[each.key].id
  ]

  admin_username = var.admin_username
  admin_password = var.admin_password

  os_disk {
    name                             = var.os_disk.name
    caching                          = var.os_disk.caching
    storage_account_type             = var.os_disk.storage_account_type
    disk_encryption_set_id           = var.os_disk.disk_encryption_set_id
    disk_size_gb                     = var.os_disk.disk_size_gb
    write_accelerator_enabled        = var.os_disk.write_accelerator_enabled
    secure_vm_disk_encryption_set_id = var.os_disk.secure_vm_disk_encryption_set_id
    security_encryption_type         = var.os_disk.security_encryption_type

    dynamic "diff_disk_settings" {
      for_each = var.os_disk.diff_disk_settings == null ? [] : [true]

      content {
        option    = var.os_disk.diff_disk_settings.option
        placement = var.os_disk.diff_disk_settings.placement
      }
    }
  }

  source_image_reference {
    offer     = var.source_image_reference.offer
    publisher = var.source_image_reference.publisher
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }

  lifecycle {
    ignore_changes = [tags["CreationDateTime"], tags["Environment"]]
  }
}

resource "azurerm_linux_virtual_machine" "vms" {
  for_each = local.is_windows ? local.vms_map : {}

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.size

  network_interface_ids = [
    azurerm_network_interface.nics[each.key].id
  ]

  disable_password_authentication = var.disable_password_authentication
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password

  dynamic "admin_ssh_key" {
    for_each = var.disable_password_authentication ? [true] : []

    content {
      username   = var.admin_username
      public_key = var.admin_public_ssh_key
    }
  }

  os_disk {
    name                             = var.os_disk.name
    caching                          = var.os_disk.caching
    storage_account_type             = var.os_disk.storage_account_type
    disk_encryption_set_id           = var.os_disk.disk_encryption_set_id
    disk_size_gb                     = var.os_disk.disk_size_gb
    write_accelerator_enabled        = var.os_disk.write_accelerator_enabled
    secure_vm_disk_encryption_set_id = var.os_disk.secure_vm_disk_encryption_set_id
    security_encryption_type         = var.os_disk.security_encryption_type

    dynamic "diff_disk_settings" {
      for_each = var.os_disk.diff_disk_settings == null ? [] : [true]

      content {
        option    = var.os_disk.diff_disk_settings.option
        placement = var.os_disk.diff_disk_settings.placement
      }
    }
  }

  source_image_reference {
    offer     = var.source_image_reference.offer
    publisher = var.source_image_reference.publisher
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }

  dynamic "identity" {
    for_each = var.identity_type == "None" ? [] : [true]

    content {
      type         = var.identity_type
      identity_ids = var.user_assigned_identities
    }
  }

  lifecycle {
    ignore_changes = [tags["CreationDateTime"], tags["Environment"]]
  }
}

locals {
  disks_map = merge([
    for vm_key, vm in local.vms_map : {
      for disk_index, disk in var.disks : "${vm.name}-${disk.name}" =>
      merge(disk, {
        name  = "${vm.name}-${disk.name}"
        lun   = disk_index
        vm_id = local.is_windows ? azurerm_windows_virtual_machine.vms[vm_key].id : azurerm_linux_virtual_machine.vms[vm_key].id
      })
    }
  ]...)
}

resource "azurerm_managed_disk" "disks" {
  for_each = local.disks_map

  name                   = each.value.name
  location               = var.location
  resource_group_name    = var.resource_group_name
  create_option          = each.value.create_option
  storage_account_type   = each.value.storage_account_type
  disk_size_gb           = each.value.disk_size_gb
  disk_encryption_set_id = each.value.disk_encryption_set_id
  disk_iops_read_write   = each.value.disk_iops_read_write
  disk_mbps_read_write   = each.value.disk_mbps_read_write
  disk_iops_read_only    = each.value.disk_iops_read_only
  disk_mbps_read_only    = each.value.disk_mbps_read_only
  upload_size_bytes      = each.value.upload_size_bytes
}

resource "azurerm_virtual_machine_data_disk_attachment" "disks_attachment" {
  for_each = local.disks_map

  managed_disk_id    = azurerm_managed_disk.disks[each.key].id
  virtual_machine_id = each.value.vm_id
  caching            = each.value.caching
  lun                = each.value.lun
}

locals {
  role_assignements_map = merge([
    for count in range(var.vm_count) : {
      for role_assignment in var.role_assignments : role_assignment.name => merge(role_assignment, {
        principal_id = local.is_windows ? azurerm_windows_virtual_machine.vms[count].identity[0].principal_id : azurerm_linux_virtual_machine.vms[count].identity[0].principal_id
      })
    }
  ]...)
}

resource "azurerm_role_assignment" "vm_roles" {
  for_each = local.role_assignements_map

  principal_id         = each.value.principal_id
  role_definition_name = each.value.role
  scope                = each.value.scope
}

module "nic_diagnostic" {
  source   = "github.com/danielkhen/diagnostic_setting_module"
  for_each = local.vms_map

  name                       = "${azurerm_network_interface.nics[each.key].name}-diagnostic"
  target_resource_id         = azurerm_network_interface.nics[each.key].id
  log_analytics_workspace_id = var.log_analytics_id
}
