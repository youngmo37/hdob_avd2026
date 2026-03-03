output "hub_vnet_id"     { value = azurerm_virtual_network.hub.id }
output "svr_subnet_id"   { value = azurerm_subnet.svr.id }
output "firewall_ip"     { value = azurerm_firewall.fw.ip_configuration[0].private_ip_address }
