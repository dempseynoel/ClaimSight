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

resource "azuread_application" "databricks_storage" {
  display_name = "sp-claimsight-databricks-${var.environment}"
}

resource "azuread_service_principal" "databricks_storage" {
  client_id = azuread_application.databricks_storage.client_id
}

resource "azuread_service_principal_password" "databricks_storage" {
  service_principal_id = azuread_service_principal.databricks_storage.object_id
  end_date_relative    = "8760h"
}

resource "azurerm_role_assignment" "databricks_storage" {
  scope                = module.storage.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.databricks_storage.object_id
}

resource "azurerm_key_vault_secret" "databricks_sp_client_id" {
  name         = "databricks-sp-client-id"
  value        = azuread_application.databricks_storage.client_id
  key_vault_id = module.key_vault.key_vault_id
  depends_on   = [module.key_vault]
}

resource "azurerm_key_vault_secret" "databricks_sp_client_secret" {
  name         = "databricks-sp-client-secret"
  value        = azuread_service_principal_password.databricks_storage.value
  key_vault_id = module.key_vault.key_vault_id
  depends_on   = [module.key_vault]
}

resource "azurerm_key_vault_secret" "databricks_sp_tenant_id" {
  name         = "databricks-sp-tenant-id"
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = module.key_vault.key_vault_id
  depends_on   = [module.key_vault]
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
