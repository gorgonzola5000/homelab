terraform {
  backend "http" {}
  encryption {
    key_provider "pbkdf2" "this" {
      passphrase = var.passphrase
    }
    method "aes_gcm" "this" {
      keys = key_provider.pbkdf2.this
    }
    state {
      method   = method.aes_gcm.this
      enforced = true
    }
  }
  required_providers {
    proxmox = {
      version = "0.93.0"
      source  = "bpg/proxmox"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.6.2"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.16.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.10.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.3.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "proxmox" {
  endpoint = "https://${local.proxmox_hostname}.${local.homelab_domain}:${var.proxmox_insecure ? "8006" : "443"}"
  insecure = var.proxmox_insecure
  username = "terraform@pam"
  password = var.proxmox_password

  ssh {
    agent       = false
    username    = "terraform"
    private_key = base64decode(var.terraform_private_key)
  }
}
