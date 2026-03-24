variable "key_vault_id" {
  type = string
}

variable "key_vault_uri" {
  type = string
}

variable "environment" {
  type = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}
