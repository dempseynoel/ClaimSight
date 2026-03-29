provider "azurerm" {
  features {}
}

provider "azuread" {}

module "claimsight" {
  source                  = "../modules/claimsight"
  environment             = var.environment
  location                = var.location
  resource_group_name     = var.resource_group_name
  storage_account_name    = var.storage_account_name
  key_vault_name          = var.key_vault_name
  workspace_name          = var.workspace_name
  db_storage_account_name = var.db_storage_account_name
}
