terraform {
  backend "azurerm" {
    resource_group_name  = "rg-claimsight-tfstate"
    storage_account_name = "stclaimsighttfstate"
    container_name       = "tfstate"
    # key is provided per environment via:
    # terraform init -backend-config=../environments/<env>/databricks.backend.hcl
  }
}
