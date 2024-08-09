provider "proxmox" {
  endpoint = var.virtual_environment_endpoint
  username = var.virtual_environment_username
  password = var.virtual_environment_password

  insecure = true

  ssh {
    agent       = true
    private_key = file("/home/gorgonzola5000/.ssh/id_ed25519")
    username    = "terraform"
  }
}
variable "virtual_environment_endpoint" {
  type = string
}
variable "virtual_environment_username" {
  type = string
}
variable "virtual_environment_password" {
  type = string
}

provider "local" {
}
