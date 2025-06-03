terraform {
  backend "http" {
  }
  required_providers {
    proxmox = {
      version = "0.78.1"
      source  = "bpg/proxmox"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4"
    }
  }
}

provider "cloudflare" {
}

provider "proxmox" {
  endpoint = "https://proxmox.${var.subdomain}.${var.domain}"
  # username and password set with env variables

  ssh {
    agent       = false
    username    = "terraform"
    private_key = base64decode(var.terraform_private_key)
  }
}

variable "terraform_private_key" {
  type = string
}

