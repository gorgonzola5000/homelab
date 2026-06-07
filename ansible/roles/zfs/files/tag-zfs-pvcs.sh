#!/bin/bash

SC_MAP=$(kubectl get sc --request-timeout=5s -o jsonpath='{range .items[*]}{.metadata.name}{"|"}{.parameters.poolname}{"\n"}{end}')

kubectl get pv --request-timeout=5s -o jsonpath='{range .items[?(@.spec.claimRef)]}{.spec.claimRef.namespace}{"|"}{.spec.claimRef.name}{"|"}{.spec.csi.volumeHandle}{"|"}{.spec.local.path}{"|"}{.spec.storageClassName}{"\n"}{end}' | while IFS='|' read -r ns pvc csi local_path sc; do
  dataset=""
  if [ -n "$local_path" ]; then
    dataset="${local_path#/}"
  elif [ -n "$csi" ]; then
    root_dataset=$(echo "$SC_MAP" | awk -F'|' -v sc_name="$sc" '$1 == sc_name {print $2}')
    if [ -n "$root_dataset" ]; then
      dataset="${root_dataset%/}/${csi}"
    else
      dataset="$csi"
    fi
  fi
  if [ -n "$dataset" ] && zfs list "$dataset" >/dev/null 2>&1; then
    zfs set k8s:namespace="$ns" "$dataset"
    zfs set k8s:pvc="$pvc" "$dataset"
  fi
done
