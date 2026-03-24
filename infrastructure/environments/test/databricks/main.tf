terraform {
  required_version = ">= 1.7.0"

  backend "azurerm" {
    resource_group_name  = "rg-claimsight-tfstate"
    storage_account_name = "stclaimsighttfstate"
    container_name       = "tfstate"
    key                  = "test/databricks.tfstate"
  }

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.40"
    }
  }
}

data "terraform_remote_state" "base" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-claimsight-tfstate"
    storage_account_name = "stclaimsighttfstate"
    container_name       = "tfstate"
    key                  = "test/claimsight.tfstate"
  }
}

provider "databricks" {
  azure_workspace_resource_id = data.terraform_remote_state.base.outputs.databricks_workspace_id
}

module "databricks_config" {
  source        = "../../../modules/databricks"
  key_vault_id  = data.terraform_remote_state.base.outputs.key_vault_id
  key_vault_uri = data.terraform_remote_state.base.outputs.key_vault_uri
  environment   = var.environment
}
