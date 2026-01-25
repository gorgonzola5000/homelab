When bootstrapping a new host, a zpool needs to be created:
`kubectl --kubeconfig=<path_to_kubeconfig> -n openebs debug node/<node_hostname> --profile=sysadmin -it --image=busybox`
`ZPOOL_DISKS=$(ls /host/dev/mapper/luks2-*)`
`CLEAN_DISKS=$(echo "$ZPOOL_DISKS" | sed 's|/host||g')`
`nsenter -t 1 -m -- zpool status`
`nsenter -t 1 -m -- zpool create -m /var/mnt/tank -O compression=lz4 -O recordsize=1M tank raidz2 $CLEAN_DISKS`
