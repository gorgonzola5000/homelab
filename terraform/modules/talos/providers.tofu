terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.10.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.3.0"
    }
  }
}
