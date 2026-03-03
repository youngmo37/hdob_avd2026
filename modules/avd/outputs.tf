# modules/avd/outputs.tf (새 파일 생성)
output "hostpool_id" {
  value = azurerm_virtual_desktop_host_pool.hp.id
}

output "workspace_id" {
  value = azurerm_virtual_desktop_workspace.ws.id
}
