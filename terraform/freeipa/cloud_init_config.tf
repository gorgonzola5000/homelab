variable "ansible_public_key" {
  type    = string
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAYine9qQWjvBhbxoEP5OFz7bWzuMwUZVPR+7VgfZd1X"
}

resource "proxmox_virtual_environment_file" "freeipa_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "proxmox"

  source_raw {
    data = <<-EOF
    #cloud-config
    allow_public_ssh_keys: true
    hostname: freeipa
    create_hostname_file: true
    fqdn: freeipa.home.parents-basement.win
    prefer_fqdn_over_hostname: true
    users:
      - name: ansible
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups:
          - sudo
          - wheel
        shell: /bin/bash
        chpasswd: 
          expire: false
        ssh_authorized_keys:
          - ${var.ansible_public_key}
    runcmd:
        - yum update
        - yum install -y qemu-guest-agent net-tools
        - timedatectl set-timezone Europe/Warsaw
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
        - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "freeipa-cloud-config.yaml"
  }
}
