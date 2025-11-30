To create the .iso for bootstrap

1. Download netinst Debian .iso into this directory. It won't get committed to git
2. Set up env variables in the appropriate file, depending on the target host. E.g. for bootstrapping host 'fearless', create fearless.prod.env for the physical host or fearless.dev.env for the virtualized, dev host for local development. Neither *.env nor preseed.cfg will get committed to git
3. Create the .iso - `bash -c 'set -a; source <env_file>; set +a; ./main.sh <debian_iso_filename> <preseeded_iso_filename>'`. It will not get committed to git

To bootstrap

1. Flash the preseeded .iso to a flash drive
2. Boot the target host using the new .iso
3. Install the preseeded Debian. Select the regular 'Install'
4. After the installation is done, run the Ansible playbook for the host

heavily inspired by <https://finalrewind.org/interblag/entry/debian-preseeding-usb-stick-with-uefi/>
