resource "azurerm_route_table" "spoke_rt" {
  name                = "${var.prefix}-spoke-rt"
  resource_group_name = var.rg_name
  location            = var.location
}

resource "azurerm_route" "to_internet" {
  name                   = "to-internet"
  resource_group_name    = var.rg_name
  route_table_name       = azurerm_route_table.spoke_rt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.fw_ip
}

resource "azurerm_subnet_route_table_association" "avd_assoc" {
  subnet_id      = azurerm_subnet.avd.id
  route_table_id = azurerm_route_table.spoke_rt.id
}

resource "azurerm_subnet_route_table_association" "dedicated_assoc" {
  subnet_id      = azurerm_subnet.dedicated.id
  route_table_id = azurerm_route_table.spoke_rt.id
}
