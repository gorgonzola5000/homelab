variable "use_bootstrap" {
  description = "Set to true ONLY for the initial Keycloak bootstrap run."
  type        = bool
  default     = false
}

variable "is_local" {
  type    = bool
  default = false
}

variable "cluster_name" {
  type = string
}
