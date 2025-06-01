# Homelab

This repository contains config files for my homelab. I try to keep everything defined in code, using Terraform [(link to provider)](https://github.com/bpg/terraform-provider-proxmox) and Ansible.

## Current state of things

<table>
  <tr>
    <th>Hardware</th>
    <th>Software</th>
  </tr>
  <tr>
    <td>Netgear R6220</td>
    <td>OpenWRT router</td>
  </tr>
  <tr>
    <td>ASUS RT-AX53U</td>
    <td>OpenWRT dumb AP</td>
  </tr>
  <tr>
    <td>Lenovo M720q
      <ul>
        <li>Intel i5-9400T</li>
        <li>40 GB DDR4</li>
        <li>1 TB SATA SSD</li>
      </ul>
    </td>
    <td>Proxmox
      <ul>
        <li>Gitlab</li>
        <li>GitLab-Runner</li>
        <li>FreeIPA</li>
        <li>Home Assistant OS</li>
        <li>General purpose server
          <ul>
            <li>Wireguard</li>
            <li>Pi-hole</li>
            <li>ddclient</li>
            <li>Glance</li>
          </ul>
        </li>
        <li>Media server
          <ul>
            <li>Jellyfin</li>
            <li>The usual</li>
          </ul>
        </li>
      </ul>
    </td>
  </tr>
  <tr>
    <td>Offline backup server
      <ul>
        <li>Intel Xeon E3-1220</li>
        <li>16 GB ECC DDR3</li>
        <li>Supermicro CSE-846</li>
        <li>BPN-SAS2-846EL1 backplane</li>
        <li>Supermicro AOC-SAS2LP-MV8 SAS controller</li>
        <li>8 TB raw, 4 TB usable RAIDZ2</li>
      </ul>
    </td>
    <td>Proxmox Backup Server</td>
  </tr>
</table>

## How to set up

1. Install Proxmox:

- download the bootable ISO and flash it onto a USB drive
- install the OS
- set up your keys (`cd /root/.ssh && touch authorized_keys && curl https://github.com/gorgonzola5000.keys >> authorized_keys`)
- on your other PC, run `ansible-playbook -u root proxmox.yml`

2. Restore VMs from a backup
