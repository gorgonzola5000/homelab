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
      method = method.aes_gcm.this
      enforced = true
    }
  }
  required_providers {
    proxmox = {
      version = "0.86.0"
      source  = "bpg/proxmox"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.13.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0-alpha.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "18.3.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.6.4"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
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

provider "gitlab" {
  token = var.gitlab_token
}

provider "flux" {
  kubernetes = {
    host                   = "https://${local.talos_ip}:6443"
    client_certificate     = base64decode(module.talos.kubernetes_client_certificate)
    client_key             = base64decode(module.talos.kubernetes_client_key)
    cluster_ca_certificate = base64decode(module.talos.kubernetes_cluster_ca_certificate)
  }
  git = {
    url = "ssh://git@gitlab.com/${data.gitlab_project.this.path_with_namespace}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux.private_key_pem
    }
  }
}

provider "kubernetes" {
  host                   = "https://${local.talos_ip}:6443"
  client_certificate     = base64decode(module.talos.kubernetes_client_certificate)
  client_key             = base64decode(module.talos.kubernetes_client_key)
  cluster_ca_certificate = base64decode(module.talos.kubernetes_cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = "https://${local.talos_ip}:6443"
    client_certificate     = base64decode(module.talos.kubernetes_client_certificate)
    client_key             = base64decode(module.talos.kubernetes_client_key)
    cluster_ca_certificate = base64decode(module.talos.kubernetes_cluster_ca_certificate)
  }
}
