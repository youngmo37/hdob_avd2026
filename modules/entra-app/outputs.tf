output "app_client_id" {
  value     = azuread_application.app.client_id
  sensitive = false
}

output "app_client_secret" {
  value     = azuread_service_principal_password.secret.value
  sensitive = true
}

output "app_tenant_id" {
  value     = data.azuread_client_config.current.tenant_id
  sensitive = false
}
