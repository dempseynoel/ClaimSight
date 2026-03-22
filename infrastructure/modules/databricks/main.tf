terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.40"
    }
  }
}

resource "azurerm_databricks_workspace" "claimsight" {
  name                = var.workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "premium"   # required for Unity Catalog

  custom_parameters {
    storage_account_name          = var.storage_account_name
    storage_account_sku_name      = "Standard_LRS"
  }

  tags = {
    project    = "claimsight"
    managed_by = "terraform"
  }
}

provider "databricks" {
  host = azurerm_databricks_workspace.claimsight.workspace_url
}

resource "databricks_secret_scope" "claimsight" {
  name = "claimsight"

  keyvault_metadata {
    resource_id = var.key_vault_id
    dns_name    = var.key_vault_uri
  }
}

resource "databricks_cluster_policy" "claimsight" {
  name = "ClaimSight Dev Policy"
  definition = jsonencode({
    "autotermination_minutes" : { "type" : "fixed", "value" : 20 },
    "node_type_id" : { "type" : "allowlist",
      "values" : ["Standard_DS3_v2", "Standard_DS4_v2"] },
    "spark_version" : { "type" : "unlimited",
      "defaultValue" : "15.4.x-scala2.12" }
  })
}

output "workspace_url" {
  value = azurerm_databricks_workspace.claimsight.workspace_url
}