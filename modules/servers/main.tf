locals {
  servers = {
    mgmt  = "${var.prefix}-mgmt-vm"      # Windows Server 2025 (최신)
    jump  = "${var.prefix}-jump-vm"      # Windows 11 Enterprise LTSC
    image = "${var.prefix}-image-vm"     # 이미지 작업용 Windows 11 LTSC
  }
}

# NICs
resource "azurerm_network_interface" "nic" {
  for_each            = local.servers
  name                = "${each.value}-nic"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# 관리서버: Windows Server 2025 (최신 버전)
resource "azurerm_windows_virtual_machine" "mgmt" {
  name                  = local.servers.mgmt
  resource_group_name   = var.rg_name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.admin_user
  admin_password        = var.admin_pass
  network_interface_ids = [azurerm_network_interface.nic["mgmt"].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = var.os_disk_size  # 2TB
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-azure-edition-core-smalldisk"  # 최신 2025 Core
    version   = "latest"
  }

  # RDP 포트 개방 (Firewall에서 허용됨)
  license_type = "Windows_Server"
}

# Jumpbox & 이미지서버: Windows 11 Enterprise LTSC 2024
resource "azurerm_windows_virtual_machine" "client_vms" {
  for_each              = { for k, v in local.servers : k => v if contains(["jump", "image"], k) }
  name                  = each.value
  resource_group_name   = var.rg_name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.admin_user
  admin_password        = var.admin_pass
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 128  # 128GB (Windows 11 기본)
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-24h2-ent-ltsc-azure-cvm-avd-msvm"  # LTSC 2024 AVD 최적화
    version   = "latest"
  }

  license_type = "Windows_Client"
  
  # 이미지 서버용: 이미지 커스터마이징용 Extension 추가 가능
  provisioner "remote-exec" {
    inline = ["powershell.exe -Command 'Write-Host \"Image VM Ready\"'"]
    connection {
      type     = "winrm"
      user     = var.admin_user
      password = var.admin_pass
      host     = azurerm_network_interface.nic[each.key].ip_configuration[0].private_ip_address
    }
  }
}
