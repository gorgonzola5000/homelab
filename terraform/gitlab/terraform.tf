terraform {
  required_providers {
    proxmox = {
      version = "0.78.2"
      source  = "bpg/proxmox"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
  }
}
