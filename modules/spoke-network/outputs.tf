output "spoke_vnet_id"  { value = azurerm_virtual_network.spoke.id }
output "avd_subnet_id"  { value = azurerm_subnet.avd.id }
output "ded_subnet_id"  { value = azurerm_subnet.dedicated.id }
