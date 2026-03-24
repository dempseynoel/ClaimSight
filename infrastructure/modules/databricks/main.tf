terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

resource "databricks_secret_scope" "claimsight" {
  name = "claimsight"

  keyvault_metadata {
    resource_id = var.key_vault_id
    dns_name    = var.key_vault_uri
  }
}

resource "databricks_cluster_policy" "claimsight" {
  name = "ClaimSight ${title(var.environment)} Policy"
  definition = jsonencode({
    "autotermination_minutes" : { "type" : "fixed", "value" : 20 },
    "node_type_id" : {
      "type" : "allowlist",
      "values" : ["Standard_DS3_v2", "Standard_DS4_v2"]
    },
    "spark_version" : { "type" : "unlimited", "defaultValue" : "15.4.x-scala2.12" }
  })
}
