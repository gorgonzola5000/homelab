# Homelab

This repository contains config files for my homelab. I try to keep everything defined in code, using Terraform [(link to provider)](https://github.com/bpg/terraform-provider-proxmox), Ansible and Packer.

Constant WIP

## Current state of things
  - ASUS RT-AX53U running OpenWRT
  - Cheapest 1 Gb unmanaged TP-Link switch known to mankind
  - 1 Proxmox node, set up using a single Ansible Playbook
    - i5-4590, 24 GB DDR3
  - Debian 12-based GitLab VM and GitLab Runner VM for provisioning the Proxmox node. They are kept separate from the rest of the infrastructure so that they do not need to provision themselves. They are instead built and then deployed from a different machine. Once deployed, they are used to store this repository (and mirror it to this GitHub remote), build .qcow2 images and provision the infrastructure
  - Alma Linux 9-based VM running:
    - nginx
    - rootless (where possible) Podman containers
      - Pi-hole - DNS sinkhole
      - Glance - dashboard
      - ddclient
    - Wireguard full-tunnel
  - Home Assistant VM, which I have no clue right now how to migrate to this repository

## How to set up
1. Install Proxmox:
  - download the bootable ISO and flash it onto a USB drive
  - install the OS
  - set up your keys (`curl github.com/gorgonzola5000.keys >> authorized_keys`)
  - on your other PC, run `ansible-playbook -i inventory.yml proxmox-setup.yml`
2. Set up GitLab and GitLab Runner VMs
  - build both .qcow2 images on your machine
  - transfer them to the Proxmox node, change their names to end with '.iso'
  - use terraform on your machine to bring up the VMs
  Alternatively: restore them both from a backup
3. Provision the rest of the VMs using GitLab
4. Restore Home Assistant VM from backup
