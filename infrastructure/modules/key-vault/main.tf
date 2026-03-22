data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "claimsight" {
  name                       = var.key_vault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
}

resource "azurerm_key_vault_access_policy" "developer" {
  key_vault_id = azurerm_key_vault.claimsight.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
}

resource "azurerm_key_vault_secret" "storage_key" {
  name         = "claimsight-storage-key"
  value        = var.storage_account_key
  key_vault_id = azurerm_key_vault.claimsight.id
  depends_on = [azurerm_key_vault_access_policy.developer]
}

output "key_vault_id" {
  value = azurerm_key_vault.claimsight.id
}

output "key_vault_uri" {
  value = azurerm_key_vault.claimsight.vault_uri
}

