resource "azurerm_storage_account" "claimsight" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.environment == "prod" ? "GRS" : "LRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = true
  }

  network_rules {
    default_action             = length(var.allowed_ip_ranges) > 0 || length(var.allowed_subnet_ids) > 0 ? "Deny" : "Allow"
    bypass                     = ["AzureServices"]
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  tags = var.tags


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
