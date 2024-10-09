terraform {
  required_providers {
    proxmox = {
      version = "0.66.1"
      source  = "bpg/proxmox"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
  }
}
