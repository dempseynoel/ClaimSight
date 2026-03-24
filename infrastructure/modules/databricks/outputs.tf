output "secret_scope_name" {
  value = databricks_secret_scope.claimsight.name
}

output "cluster_policy_id" {
  value = databricks_cluster_policy.claimsight.id
}
