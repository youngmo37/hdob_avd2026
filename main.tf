terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~>3.0" }
    azuread = { source = "hashicorp/azuread", version = "~>2.0" }
  }
}

provider "azurerm" { features {} }
provider "azuread" {}

# RG
resource "azurerm_resource_group" "hub_rg" {
  name     = "${var.prefix}-hub-rg"
  location = var.location
}

resource "azurerm_resource_group" "spoke_rg" {
  name     = "${var.prefix}-spoke-rg"
  location = var.location
}

# Hub Network Module
module "hub_network" {
  source = "./modules/hub-network"

  prefix     = var.prefix
  location   = var.location
  rg_name    = azurerm_resource_group.hub_rg.name
  vnet_cidr  = var.hub_cidr
  onprem_cidr = var.onprem_cidr
  depends_on = [azurerm_resource_group.hub_rg]
}

# Spoke Network Module
module "spoke_network" {
  source = "./modules/spoke-network"

  prefix      = var.prefix
  location    = var.location
  rg_name     = azurerm_resource_group.spoke_rg.name
  vnet_cidr   = var.spoke_cidr
  hub_vnet_id = module.hub_network.hub_vnet_id
  fw_ip       = module.hub_network.firewall_ip
  depends_on  = [azurerm_resource_group.spoke_rg, module.hub_network]
}

# Hub Servers Module
module "hub_servers" {
  source = "./modules/servers"

  prefix        = var.prefix
  location      = var.location
  rg_name       = azurerm_resource_group.hub_rg.name
  subnet_id     = module.hub_network.svr_subnet_id
  vm_size       = "Standard_D4as_v5"
  admin_user    = var.vm_admin_username
  ssh_key       = var.ssh_public_key
  os_disk_size  = 2048  # 2TB
  depends_on    = [module.hub_network]
}

# Storage Module (FSLogix/NAS)
module "storage" {
  source = "./modules/storage"

  prefix   = var.prefix
  location = var.location
  rg_name  = azurerm_resource_group.spoke_rg.name
  quota_gb = 10
}

# AVD Module
module "avd" {
  source = "./modules/avd"

  prefix       = var.prefix
  location     = var.location
  rg_name      = azurerm_resource_group.spoke_rg.name
  subnet_id    = module.spoke_network.avd_subnet_id
  vm_size      = "Standard_D4as_v5"
  os_disk_size = 128
  image_id     = var.avd_image_id
  fslogix_share = module.storage.fslogix_share_name
  domain       = "hdobpoc.com"
  depends_on   = [module.spoke_network, module.storage]
}

# Entra App Module
module "entra_app" {
  source = "./modules/entra-app"

  prefix = var.prefix
  avd_scope = module.avd.hostpool_id
}
