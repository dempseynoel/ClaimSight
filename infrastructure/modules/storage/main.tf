resource "azurerm_storage_account" "claimsight" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = true
  }
}

locals {
  containers = ["raw", "processed", "artefacts"]
}

resource "azurerm_storage_container" "layers" {
  for_each              = toset(local.containers)
  name                  = each.value
  storage_account_name  = azurerm_storage_account.claimsight.name
  container_access_type = "private"
}

output "storage_account_id" {
  value = azurerm_storage_account.claimsight.id
}

output "storage_account_name" {
  value = azurerm_storage_account.claimsight.name
}

output "primary_access_key" {
  value = azurerm_storage_account.claimsight.primary_access_key
}
