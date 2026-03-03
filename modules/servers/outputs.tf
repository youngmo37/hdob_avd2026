output "mgmt_ip" {
  value = azurerm_network_interface.nic["mgmt"].ip_configuration[0].private_ip_address
}

output "jump_ip" {
  value = azurerm_network_interface.nic["jump"].ip_configuration[0].private_ip_address
}

output "image_ip" {
  value = azurerm_network_interface.nic["image"].ip_configuration[0].private_ip_address
}

output "all_vm_ips" {
  value = {
    mgmt  = azurerm_network_interface.nic["mgmt"].ip_configuration[0].private_ip_address
    jump  = azurerm_network_interface.nic["jump"].ip_configuration[0].private_ip_address
    image = azurerm_network_interface.nic["image"].ip_configuration[0].private_ip_address
  }
}
