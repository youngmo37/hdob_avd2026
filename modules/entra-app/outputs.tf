# modules/entra-app/outputs.tf (새 파일)
output "app_id" {
  value = azuread_application.app.client_id
}

output "sp_id" {
  value = azuread_service_principal.sp.object_id
}

output "client_secret" {
  value     = azuread_service_principal_password.secret.value
  sensitive = true
}
