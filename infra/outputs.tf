output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "function_app_url" {
  description = "Base hostname of the Function App"
  value       = azurerm_linux_function_app.func.default_hostname
}

output "storage_connection_string" {
  description = "Connection string for the Storage Account"
  value       = azurerm_storage_account.sa.primary_connection_string
  sensitive   = true
}
