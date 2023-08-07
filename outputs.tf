output "names" {
  description = "A list of all virtual machines names."
  value       = local.is_windows ? values(azurerm_windows_virtual_machine.vms).*.name : values(azurerm_linux_virtual_machine.vms).*.name
}

output "ids" {
  description = "A list of all virtual machines ids."
  value       = local.is_windows ? values(azurerm_windows_virtual_machine.vms).*.id : values(azurerm_linux_virtual_machine.vms).*.id
}

output "objects" {
  description = "A list of all virtual machines."
  value       = local.is_windows ? values(azurerm_windows_virtual_machine.vms) : values(azurerm_linux_virtual_machine.vms)
}

output "private_ips" {
  description = "A list of all the private ip addresses of the virtual machines."
  value       = local.is_windows ? values(azurerm_windows_virtual_machine.vms).*.private_ip_address : values(azurerm_linux_virtual_machine.vms).*.private_ip_address
}