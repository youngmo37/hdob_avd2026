data "azuread_client_config" "current" {}

resource "azuread_application" "app" {
  display_name    = "${var.prefix}-avd-mgmt-app"
  sign_in_audience = "AzureADMyOrg"
}

resource "azuread_service_principal" "sp" {
  client_id = azuread_application.app.client_id # ✅ 수정
}

resource "azuread_service_principal_password" "secret" {
  service_principal_id = azuread_service_principal.sp.object_id
  display_name         = "avd-mgmt-secret"
  end_date             = timeadd(timestamp(), "8760h")
}

resource "azurerm_role_assignment" "avd_role" {
  scope                = var.avd_scope
  role_definition_name = "Desktop Virtualization Contributor"
  principal_id         = azuread_service_principal.sp.object_id
}
