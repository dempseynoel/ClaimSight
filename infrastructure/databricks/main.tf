data "terraform_remote_state" "base" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-claimsight-tfstate"
    storage_account_name = "stclaimsighttfstate"
    container_name       = "tfstate"
    key                  = var.base_state_key
  }
}

provider "databricks" {
  azure_workspace_resource_id = data.terraform_remote_state.base.outputs.databricks_workspace_id
}

module "databricks_config" {
  source        = "../modules/databricks"
  key_vault_id  = data.terraform_remote_state.base.outputs.key_vault_id
  key_vault_uri = data.terraform_remote_state.base.outputs.key_vault_uri
  environment   = var.environment
}
