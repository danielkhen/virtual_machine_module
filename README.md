<!-- BEGIN_TF_DOCS -->

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | (Optional) The username of the admin user in the virtual machines, Required when password authentication enabled. | `string` | `null` | no |
| <a name="input_admin_public_ssh_key"></a> [admin\_public\_ssh\_key](#input\_admin\_public\_ssh\_key) | (Optional) The public ssh key of the admin user, Required when password authentication disabled. | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | (Required) The username of the admin user in the virtual machines, Required when password authentication enabled. | `string` | n/a | yes |
| <a name="input_disable_password_authentication"></a> [disable\_password\_authentication](#input\_disable\_password\_authentication) | (Optional) Allow ssh connection in linux virtual machines. | `string` | `false` | no |
| <a name="input_disks"></a> [disks](#input\_disks) | (Optional) A list of managed disk to attach to the virtual machines. | <pre>list(object({<br>    name                   = string<br>    storage_account_type   = string<br>    create_option          = string<br>    caching                = string<br>    disk_size_gb           = number<br>    disk_encryption_set_id = optional(string, null)<br>    disk_iops_read_write   = optional(number, null)<br>    disk_mbps_read_write   = optional(number, null)<br>    disk_iops_read_only    = optional(number, null)<br>    disk_mbps_read_only    = optional(number, null)<br>    upload_size_bytes      = optional(number, null)<br>  }))</pre> | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | (Optional) The type of the identity of the virtual machines. | `string` | `"None"` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) The location of the virtual machines. | `string` | n/a | yes |
| <a name="input_log_analytics_id"></a> [log\_analytics\_id](#input\_log\_analytics\_id) | (Required) The id of the log analytics workspace. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the virtual machines. | `string` | n/a | yes |
| <a name="input_nic_name"></a> [nic\_name](#input\_nic\_name) | (Required) The name of the network interface. | `string` | n/a | yes |
| <a name="input_os_disk"></a> [os\_disk](#input\_os\_disk) | (Required) An object defining the disk containing the operation system for the virtual machines. | <pre>object({<br>    caching                          = string<br>    storage_account_type             = string<br>    name                             = optional(string, null)<br>    disk_size_gb                     = optional(number, null)<br>    write_accelerator_enabled        = optional(bool, false)<br>    disk_encryption_set_id           = optional(string, null)<br>    secure_vm_disk_encryption_set_id = optional(string, null)<br>    security_encryption_type         = optional(string, null)<br>    diff_disk_settings = optional(object({<br>      option    = string<br>      placement = optional(string, null)<br>    }), null)<br>  })</pre> | n/a | yes |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | (Required) The os type of the vm, Linux or Windows. | `string` | n/a | yes |
| <a name="input_public_ip_enabled"></a> [public\_ip\_enabled](#input\_public\_ip\_enabled) | (Optional) Should the virtual machines have public ips attached. | `bool` | `false` | no |
| <a name="input_public_ip_name"></a> [public\_ip\_name](#input\_public\_ip\_name) | (Optional) The name of the public ip of the virtual machines, Required when public ip is enabled. | `string` | `null` | no |
| <a name="input_public_ip_sku"></a> [public\_ip\_sku](#input\_public\_ip\_sku) | (Optional) The sku of the public ips of the virtual machines. | `string` | `"Basic"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (required) The resource group name of the virtual machines. | `string` | n/a | yes |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | (Optional) A list of rules for the system identity, system assigned identity must be enabled. | <pre>list(object({<br>    name  = string<br>    scope = string<br>    role  = string<br>  }))</pre> | `[]` | no |
| <a name="input_size"></a> [size](#input\_size) | (Required) The size of the virtual machines. | `string` | n/a | yes |
| <a name="input_source_image_reference"></a> [source\_image\_reference](#input\_source\_image\_reference) | (Required) An object defining the source image for the virtual machines. | <pre>object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>    version   = string<br>  })</pre> | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | (Required) The subnet id of the network interfaces. | `string` | n/a | yes |
| <a name="input_user_assigned_identities"></a> [user\_assigned\_identities](#input\_user\_assigned\_identities) | (Optional) A list of ids of user assigned identities for each virtual machine, user assigned identity must be enabled. | `list(string)` | `null` | no |
| <a name="input_vm_count"></a> [vm\_count](#input\_vm\_count) | (Optional) The number of virtual machines to create with this configurations. | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ids"></a> [ids](#output\_ids) | A list of all virtual machines ids. |
| <a name="output_names"></a> [names](#output\_names) | A list of all virtual machines names. |
| <a name="output_objects"></a> [objects](#output\_objects) | A list of all virtual machines. |
| <a name="output_private_ips"></a> [private\_ips](#output\_private\_ips) | A list of all the private ip addresses of the virtual machines. |

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.vms](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_managed_disk.disks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_network_interface.nics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_public_ip.ips](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_role_assignment.vm_roles](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_virtual_machine_data_disk_attachment.disks_attachment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_windows_virtual_machine.vms](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_nic_diagnostic"></a> [nic\_diagnostic](#module\_nic\_diagnostic) | github.com/danielkhen/diagnostic_setting_module | n/a |

## Example Code

```hcl
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

  identity_type = "SystemAssigned"
  #View variable documentation
  role_assignments = local.role_assignments
  disks            = local.disks

  log_analytics_id = module.hub_log_analytics.id
}
```
<!-- END_TF_DOCS -->