variable "environment" {
  type = string
}

variable "base_state_key" {
  type        = string
  description = "State file key for the base infrastructure, used to read outputs via terraform_remote_state"
}
