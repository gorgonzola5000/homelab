Ansible uses SSH and I use it as my main provisioner for images. That's why a key pair needs to be generated for each image (in each subdirectory):
`ssh-keygen -f packer_key`
Then modify 'user-data' file.

To use packer install:
 - xorriso
 - qemu
 - ansible
 - packer
