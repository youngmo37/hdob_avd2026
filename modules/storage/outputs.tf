output "storage_account_name" { value = azurerm_storage_account.sa.name }
output "fslogix_share_name"   { value = azurerm_storage_share.fslogix.name }
output "nas_share_name"       { value = azurerm_storage_share.nas_profile.name }
