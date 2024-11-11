packer {
  required_plugins {
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
    qemu = {
      version = "~> 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "gitlab" {
  accelerator               = "kvm"
  boot_command              = []
  disk_compression          = true
  disk_interface            = "virtio"
  disk_image                = true
  disk_size                 = "20000M"
  boot_wait                 = "10s"
  vm_name                   = "gitlab.qcow2"
  format                    = "qcow2"
  memory                    = "8192"
  headless                  = "false"
  iso_checksum              = "file:https://cloud.debian.org/images/cloud/bookworm/latest/SHA512SUMS"
  iso_url                   = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
  net_device                = "virtio-net"
  output_directory          = "images"
  cd_files                  = ["./user-data", "./meta-data"]
  cd_label                  = "CIDATA"
  communicator              = "ssh"
  host_port_min             = 2222
  host_port_max             = 2299
  shutdown_timeout          = "1m"
  shutdown_command          = "shutdown -P now"
  ssh_username              = "root"
  ssh_private_key_file      = "./packer_key"
  ssh_clear_authorized_keys = true
  ssh_timeout               = "60s"
}

build {
  sources = ["source.qemu.gitlab"]

  provisioner "ansible" {
    playbook_file = "../../ansible/gitlab.yml"
       extra_arguments = [ "--vault-password-file=../../ansible/vault-pass.sh", "--extra-vars", "target=default" ]
  }
}
