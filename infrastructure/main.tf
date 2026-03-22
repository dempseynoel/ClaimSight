terraform {
  required_version = ">= 1.7.0"

  backend "azurerm" {
    resource_group_name  = "rg-claimsight-tfstate"
    storage_account_name = "stclaimsighttfstate"
    container_name       = "tfstate"
    key                  = "claimsight.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.40"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_resource_group" "claimsight" {
  name     = local.resource_group_name
  location = local.location
  tags     = { project = "claimsight", managed_by = "terraform" }
}

module "storage" {
  source               = "./modules/storage"
  resource_group_name  = azurerm_resource_group.claimsight.name
  location             = local.location
  storage_account_name = var.storage_account_name
}

module "key_vault" {
  source              = "./modules/key-vault"
  resource_group_name = azurerm_resource_group.claimsight.name
  location            = local.location
  key_vault_name      = var.key_vault_name
  storage_account_key = module.storage.primary_access_key
}

module "databricks" {
  source               = "./modules/databricks"
  resource_group_name  = azurerm_resource_group.claimsight.name
  location             = local.location
  workspace_name       = var.workspace_name
  storage_account_name = var.db_storage_account_name
  key_vault_id         = module.key_vault.key_vault_id
  key_vault_uri        = module.key_vault.key_vault_uri
}
