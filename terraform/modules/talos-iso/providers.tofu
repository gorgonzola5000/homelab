terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.10.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}
