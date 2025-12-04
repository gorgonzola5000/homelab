variable "proxmox_hostname" {
  type        = string
  description = "Proxmox hostname"
}

variable "talos_ram" {
  type        = number
  description = "MiB of ram for the Talos VM"
}

variable "talos_ip" {
  type = string
}

variable "gateway_ip" {
  type = string
}

variable "talos_mac_address" {
  type = string
}

variable "talos_cluster_name" {
  type = string
}

variable "talos_hostname" {
  type = string
}

variable "terraform_private_key" {
  type      = string
  sensitive = true
}

variable "talos_kubernetes_endpoint" {
  type = string
}

variable "proxmox_ip" {
  type = string
}

variable "proxmox_insecure" {
  type = bool
}

variable "cloudflare_api_token" {
  type = string
}

variable "proxmox_password" {
  type = string
}

variable "gitlab_token" {
  type = string
}

variable "proxmox_physical_host" {
  type = bool
}

variable "passphrase" {
  type        = string
  sensitive   = true
  description = "State encryption passphrase"
}

variable "talos_zfs_pool_passphrase" {
  type      = string
  sensitive = true
}

variable "talos_disk_wwids" {
  type        = list(string)
  description = "List of Disk WWIDs"
}
