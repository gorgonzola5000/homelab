provider "proxmox" {
  endpoint = var.virtual_environment_endpoint

  username = var.virtual_environment_username
  password = var.virtual_environment_password

  insecure = true

  ssh {
    agent       = false
    username    = "terraform"
    private_key = var.terraform_private_key
    #file("/home/gorgonzola5000/.ssh/id_ed25519")

    node {
      name    = "pve"
      address = "10.2.137.3"
    }
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
variable "terraform_private_key" {
  type = string
}
