terraform {
  required_version = ">= 1.7.0"

  backend "azurerm" {
    resource_group_name  = "rg-claimsight-tfstate"
    storage_account_name = "stclaimsighttfstate"
    container_name       = "tfstate"
    key                  = "dev/claimsight.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

provider "azurerm" {
  features {}
}

module "claimsight" {
  source                  = "../../../modules/claimsight"
  environment             = var.environment
  location                = var.location
  resource_group_name     = var.resource_group_name
  storage_account_name    = var.storage_account_name
  key_vault_name          = var.key_vault_name
  workspace_name          = var.workspace_name
  db_storage_account_name = var.db_storage_account_name
}
