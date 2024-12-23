variable "ansible_public_key" {
  type    = string
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAYine9qQWjvBhbxoEP5OFz7bWzuMwUZVPR+7VgfZd1X"
}

resource "proxmox_virtual_environment_file" "cloud_config_apt" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    data = <<-EOF
    #cloud-config
    users:
      - name: ansible
        groups:
          - sudo
          - wheel
        shell: /bin/bash
        ssh_authorized_keys:
          - ${var.ansible_public_key}
    runcmd:
        - apt update && apt full-upgrade
        - apt install -y qemu-guest-agent net-tools
        - timedatectl set-timezone Europe/Warsaw
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
        - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "cloud-config-apt-${var.environment}.yaml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_config_yum" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    data = <<-EOF
    #cloud-config
    users:
      - name: ansible
        groups:
          - sudo
          - wheel
        shell: /bin/bash
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

    file_name = "cloud-config-yum-${var.environment}.yaml"
  }
}
