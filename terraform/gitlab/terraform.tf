terraform {
  required_providers {
    proxmox = {
      version = "0.78.0"
      source  = "bpg/proxmox"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
  }
}
