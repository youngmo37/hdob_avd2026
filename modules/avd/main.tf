# Host Pool
resource "azurerm_virtual_desktop_host_pool" "hp" {
  name                = "${var.prefix}-hp"
  location            = var.location
  resource_group_name = var.rg_name
  type                = "Pooled"
  load_balancer_type  = "BreadthFirst"
  maximum_sessions_allowed = 10
  preferred_app_group_type = "Desktop"

  custom_rdp_properties = "targetisaadjoined:i:1;enablerdsaadauth:i:1;"

  vm_template = jsonencode({
    vmSize       = var.vm_size
    osDiskSizeGB = var.os_disk_size
    galleryImageId = var.image_id
  })
}

resource "azurerm_virtual_desktop_workspace" "ws" {
  name                = "${var.prefix}-ws"
  location            = var.location
  resource_group_name = var.rg_name
}

resource "azurerm_virtual_desktop_application_group" "dag" {
  name                = "${var.prefix}-dag"
  location            = var.location
  resource_group_name = var.rg_name
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.hp.id
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "assoc" {
  workspace_id         = azurerm_virtual_desktop_workspace.ws.id
  application_group_id = azurerm_virtual_desktop_application_group.dag.id
}

# AVD Private DNS (관리용)
resource "azurerm_private_dns_zone" "avd" {
  name                = "privatelink.wvd.microsoft.com"
  resource_group_name = var.rg_name
}

# Private Endpoint 예시 (관리서버에서 AVD 제어용)
# 실제 subresource_names는 서비스에 따라 조정 필요 [web:29]
