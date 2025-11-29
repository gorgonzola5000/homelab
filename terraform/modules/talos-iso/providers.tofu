terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0-alpha.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}
