# Homelab
Constant WIP
This repository contains config files for my homelab. I try to keep everything defined in code using Terraform, Ansible and Packer.

## Current state of things
1 Proxmox node setup using a single Ansible Playbook

To install Proxmox:
  - download bootable ISO and flash it onto USB drive
  - install the OS
  - setup your keys (`curl github.com/gorgonzola5000.keys >> authorized_keys`)
  - on your other PC run `ansible-playbook -i inventory.yml proxmox-setup.yml`

Terraform [(link to provider)](https://github.com/bpg/terraform-provider-proxmox) to manage immutable infrastructure -  guest VMs on said Proxmox node.

Each VM is an image built using Packer and QEMU builder provisioned with Ansible.


