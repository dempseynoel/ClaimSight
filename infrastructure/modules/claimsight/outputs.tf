output "databricks_workspace_url" {
  value = azurerm_databricks_workspace.claimsight.workspace_url
}

output "databricks_workspace_id" {
  value = azurerm_databricks_workspace.claimsight.id
}

output "key_vault_id" {
  value = module.key_vault.key_vault_id
}

output "key_vault_uri" {
  value = module.key_vault.key_vault_uri
}

output "storage_account_id" {
  value = module.storage.storage_account_id
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}
