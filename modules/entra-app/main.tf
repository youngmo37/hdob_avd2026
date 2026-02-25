data "azuread_client_config" "current" {}

resource "azuread_application" "app" {
  display_name    = "${var.prefix}-avd-mgmt-app"
  sign_in_audience = "AzureADMyOrg"
}

resource "azuread_service_principal" "sp" {
  application_id = azuread_application.app.application_id
  depends_on     = [azuread_application.app]
}

# ✅ 올바른 리소스: Service Principal Password
resource "azuread_service_principal_password" "secret" {
  service_principal_id = azuread_service_principal.sp.object_id  # SP object_id 사용
  display_name         = "avd-mgmt-secret"
  
  # end_date_relative는 deprecated, timeadd() 사용 권장
  end_date = timeadd(timestamp(), "8760h")  # 1년 후 (24*365h)
}

resource "azurerm_role_assignment" "avd_role" {
  scope                = var.avd_scope
  role_definition_name = "Desktop Virtualization Contributor"
  principal_id         = azuread_service_principal.sp.object_id
  
  depends_on = [azuread_service_principal.sp]
}
