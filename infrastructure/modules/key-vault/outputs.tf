output "key_vault_id" {
  value = azurerm_key_vault.claimsight.id
}

output "key_vault_uri" {
  value = azurerm_key_vault.claimsight.vault_uri
}

output "access_policy_id" {
  value = azurerm_key_vault_access_policy.deployer.id
}