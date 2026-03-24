data "azurerm_client_config" "current" {}

locals {
  tags = {
    project     = "claimsight"
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "azurerm_resource_group" "claimsight" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

module "storage" {
  source               = "../storage"
  resource_group_name  = azurerm_resource_group.claimsight.name
  location             = var.location
  storage_account_name = var.storage_account_name
  environment          = var.environment
  allowed_ip_ranges    = var.allowed_ip_ranges
  allowed_subnet_ids   = var.allowed_subnet_ids
  tags                 = local.tags
}

module "key_vault" {
  source              = "../key-vault"
  resource_group_name = azurerm_resource_group.claimsight.name
  location            = var.location
  key_vault_name      = var.key_vault_name
  environment         = var.environment
  allowed_ip_ranges   = var.allowed_ip_ranges
  allowed_subnet_ids  = var.allowed_subnet_ids
  tags                = local.tags
}

resource "azurerm_databricks_workspace" "claimsight" {
  name                = var.workspace_name
  resource_group_name = azurerm_resource_group.claimsight.name
  location            = var.location
  sku                 = "premium"

  custom_parameters {
    storage_account_name     = var.db_storage_account_name
    storage_account_sku_name = var.environment == "prod" ? "Standard_GRS" : "Standard_LRS"
  }

  tags = local.tags


}

resource "azurerm_role_assignment" "databricks_storage" {
  count                = length(azurerm_databricks_workspace.claimsight.storage_account_identity)
  scope                = module.storage.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_workspace.claimsight.storage_account_identity[count.index].principal_id
}
