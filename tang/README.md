How to set up tang for the first time:

1. Log in to RedHat registry
2. Run the tang container
  prod - `podman run -d -p 7500:8080 -v tang-keys:/var/db/tang --name tang registry.redhat.io/rhel10/tang`
  dev - `podman run -d -p 7500:8080 -v tang-keys-dev:/var/db/tang --name tang-dev registry.redhat.io/rhel10/tang`
3. Generate tang.yml file
  `podman kube generate tang -f tang.yml`
  `podman kube generate tang-dev -f tang-dev.yml`
4. Kill and remove the container
  `podman kill tang && podman container rm tang`
  `podman kill tang-dev && podman container rm tang-dev`
5. Run `podman kube play tang.yml`
6. Bootstrap the host running Clevis
7. Stop tang `podman kube down tang.yml`

How to use tang:

1. Run `podman kube play tang.yml`
2. Boot up the host running Clevis
3. Profit
4. Stop tang `podman kube down tang.yml`

To backup keys:

1. Set up Clevis on the target machines and bind it to the Tang instance first
2. Export and encrypt the volume `podman volume export tang-keys | age -r <your_public_ssh_key> -o tang-keys.age`
