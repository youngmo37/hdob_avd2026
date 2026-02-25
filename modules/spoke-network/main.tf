resource "azurerm_virtual_network" "spoke" {
  name                = "${var.prefix}-spoke-vnet"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "avd" {
  name                 = "avd-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.175.1.0/25"]
}

resource "azurerm_subnet" "dedicated" {
  name                 = "dedicated-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.175.1.128/25"]
}

# Peering
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "spoke-to-hub"
  resource_group_name       = var.rg_name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = var.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = true
}
