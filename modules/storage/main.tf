resource "random_string" "sa" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_storage_account" "sa" {
  name                     = "st${var.prefix}${random_string.sa.result}"
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  enable_https_traffic_only = true
  large_file_share_enabled  = true
}

resource "azurerm_storage_share" "fslogix" {
  name                 = "fslogix"
  storage_account_name = azurerm_storage_account.sa.name
  quota                = var.quota_gb
}

resource "azurerm_storage_share" "nas_profile" {
  name                 = "nas-profile"
  storage_account_name = azurerm_storage_account.sa.name
  quota                = var.quota_gb
}
