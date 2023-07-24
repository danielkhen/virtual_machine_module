output "names" {
  description = "A list of all virtual machines names."
  value       = local.is_windows ? azurerm_windows_virtual_machine.vms[*].name : azurerm_linux_virtual_machine.vms[*].name
}

output "ids" {
  description = "A list of all virtual machines ids."
  value       = local.is_windows ? azurerm_windows_virtual_machine.vms[*].id : azurerm_linux_virtual_machine.vms[*].id
}

output "objects" {
  description = "A list of all virtual machines."
  value       = local.is_windows ? azurerm_windows_virtual_machine.vms : azurerm_linux_virtual_machine.vms
}

output "private_ips" {
  description = "A list of all the private ip addresses of the virtual machines."
  value       = local.is_windows ? azurerm_windows_virtual_machine.vms[*].private_ip_address : azurerm_linux_virtual_machine.vms[*].private_ip_address
}