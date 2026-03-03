resource "azurerm_virtual_network" "hub" {
  name                = "${var.prefix}-hub-vnet"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.175.0.192/27"]
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.175.0.0/26"]
}

resource "azurerm_subnet" "svr" {
  name                 = "svr-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.175.0.64/27"]
}

# ER Gateway
resource "azurerm_public_ip" "ergw_pip" {
  name                = "${var.prefix}-ergw-pip"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_network_gateway" "ergw" {
  name                   = "${var.prefix}-ergw"
  location               = var.location
  resource_group_name    = var.rg_name
  type                   = "ExpressRoute"
  # vpn_gateway_generation = "Generation2"
  sku                    = "Standard"

  ip_configuration {
    name              = "default"
    subnet_id         = azurerm_subnet.gateway.id
    public_ip_address_id = azurerm_public_ip.ergw_pip.id
  }
}

# Firewall Standard (VNet SKU)
resource "azurerm_public_ip" "fw_pip" {
  name                = "${var.prefix}-fw-pip"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "fw" {
  name                = "${var.prefix}-fw"
  resource_group_name = var.rg_name
  location            = var.location
  sku_name            = "AZFW_VNet"  # ✅ 수정: Standard → VNet
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "fw-ip-config"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }

  firewall_policy_id = azurerm_firewall_policy.policy.id  # ✅ 직접 연결
}

# Firewall Policy
resource "azurerm_firewall_policy" "policy" {
  name                = "${var.prefix}-fw-policy"
  resource_group_name = var.rg_name
  location            = var.location
  sku                 = "Standard"
}

# Rule Collection Group (priority 추가)
resource "azurerm_firewall_policy_rule_collection_group" "outbound" {
  name               = "outbound-allow-all"
  firewall_policy_id = azurerm_firewall_policy.policy.id
  priority           = 100  # ✅ 추가

  network_rule_collection {
    name     = "allow-all-outbound"
    priority = 200
    action   = "Allow"
    rule {
      name                  = "all-outbound"
      source_addresses      = ["10.175.0.0/16", "*"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
      protocols             = ["TCP", "UDP", "ICMP"]
    }
  }
}

# Policy Association 삭제 ❌ (위에서 직접 연결됨)

# resource "azurerm_firewall_policy_association" "assoc" {
#   firewall_id        = azurerm_firewall.fw.id
#   firewall_policy_id = azurerm_firewall_policy.policy.id
# }

# Hub RouteTable (인터넷 + 온프레미스 모두 FW 경유)
resource "azurerm_route_table" "hub_rt" {
  name                = "${var.prefix}-hub-rt"
  resource_group_name = var.rg_name
  location            = var.location
}

resource "azurerm_route" "to_internet" {
  name                   = "to-internet"
  resource_group_name    = var.rg_name
  route_table_name       = azurerm_route_table.hub_rt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
}

resource "azurerm_route" "to_onprem" {
  name                   = "to-onprem"
  resource_group_name    = var.rg_name
  route_table_name       = azurerm_route_table.hub_rt.name
  address_prefix         = var.onprem_cidr
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
}

resource "azurerm_subnet_route_table_association" "svr_assoc" {
  subnet_id      = azurerm_subnet.svr.id
  route_table_id = azurerm_route_table.hub_rt.id
}
