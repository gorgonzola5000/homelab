#!/usr/bin/env python3
import subprocess
import time
import sys
import os
from kubernetes import client, config
from kubernetes.client.rest import ApiException

PASSIVE_ROOT = os.environ.get("ZFS_PASSIVE_DATASET")
ACTIVE_ROOT = os.environ.get("ZFS_ACTIVE_DATASET")
PASSIVE_OPENEBS = os.environ.get("ZFS_PASSIVE_OPENEBS_DATASET")
ACTIVE_OPENEBS = os.environ.get("ZFS_ACTIVE_OPENEBS_DATASET")
RKE2_KUBECONFIG = os.environ.get("RKE2_KUBECONFIG_PATH")

try:
    config.load_kube_config(config_file=RKE2_KUBECONFIG)
    core_api = client.CoreV1Api()
    crd_api = client.CustomObjectsApi()
    api_client = client.ApiClient()
except Exception as e:
    print(f"CRITICAL: Failed to load Kubeconfig: {e}")
    sys.exit(1)

FLUX_GROUP = "kustomize.toolkit.fluxcd.io"
FLUX_VERSION = "v1"
FLUX_PLURAL = "kustomizations"
ZFS_GROUP = "zfs.openebs.io"
ZFS_VERSION = "v1"
ZFS_PLURAL = "zfsvolumes"


def run_zfs(cmd, check=True):
    """Executes a ZFS command safely."""
    full_cmd = ["zfs"] + cmd
    result = subprocess.run(full_cmd, text=True, capture_output=True)
    if check and result.returncode != 0:
        print(f"CRITICAL ZFS ERROR: {' '.join(full_cmd)}")
        print(f"STDERR: {result.stderr.strip()}")
        sys.exit(1)
    return result.stdout.strip()


def clean_manifest(obj_instance):
    """Sanitizes API objects for recreation by stripping cluster-injected state."""
    obj = api_client.sanitize_for_serialization(obj_instance)

    meta = obj.get("metadata", {})
    for key in [
        "uid",
        "resourceVersion",
        "creationTimestamp",
        "finalizers",
        "generation",
    ]:
        meta.pop(key, None)

    anns = meta.get("annotations", {})
    for a_key in [
        "pv.kubernetes.io/bind-completed",
        "pv.kubernetes.io/bound-by-controller",
        "pv.kubernetes.io/provisioned-by",
        "volume.kubernetes.io/selected-node",
        "volume.beta.kubernetes.io/storage-provisioner",
    ]:
        anns.pop(a_key, None)

    obj.pop("status", None)

    if obj.get("kind") == "PersistentVolume":
        claim = obj.get("spec", {}).get("claimRef", {})
        claim.pop("uid", None)
        claim.pop("resourceVersion", None)

    return obj


def wait_for_k8s(max_retries=30, delay=10):
    """Polls the Kubernetes API until it becomes responsive."""
    print("\n=== Waiting for Kubernetes API ===")
    for i in range(max_retries):
        try:
            core_api.list_node()
            print("  -> Kubernetes API is up and responding!")
            return
        except Exception:
            print(f"  -> API not ready yet, retrying... ({i+1}/{max_retries})")
            time.sleep(delay)
    print("CRITICAL: Timed out waiting for Kubernetes API to start.")
    sys.exit(1)


def wait_for_flux(timeout=300):
    """Waits for all Flux Kustomizations to reach the Ready state."""
    print("\n=== Waiting for Flux Kustomizations to Reconcile ===")
    start_time = time.time()

    while time.time() - start_time < timeout:
        try:
            kusts = crd_api.list_cluster_custom_object(
                FLUX_GROUP, FLUX_VERSION, FLUX_PLURAL
            )
            items = kusts.get("items", [])

            if not items:
                time.sleep(5)
                continue

            all_ready = True
            for item in items:
                conditions = item.get("status", {}).get("conditions", [])
                is_ready = any(
                    c.get("type") == "Ready" and c.get("status") == "True"
                    for c in conditions
                )

                if not is_ready:
                    all_ready = False
                    break

            if all_ready:
                print("  -> All Flux Kustomizations are Ready!")
                return

        except ApiException:
            pass

        time.sleep(5)
    print(
        "  -> Warning: Timed out waiting for Flux Kustomizations to be Ready. Proceeding..."
    )


def promote_non_openebs():
    print("=== Promoting Non-OpenEBS Custom Datasets ===")

    if not run_zfs(["list", ACTIVE_ROOT], check=False):
        run_zfs(["create", "-p", ACTIVE_ROOT])

    out = run_zfs(["list", "-H", "-o", "name", "-d", "1", PASSIVE_ROOT], check=False)
    children = [line for line in out.splitlines() if line and line != PASSIVE_ROOT]

    if not children:
        print(f"No datasets found in {PASSIVE_ROOT}.")
        return

    for ds in children:
        if ds == PASSIVE_OPENEBS:
            continue

        target_ds = f"{ACTIVE_ROOT}/{ds.split('/')[-1]}"
        print(f"----------------------------------------------------")
        print(f"Processing custom dataset: {ds}")

        snaps = run_zfs(
            [
                "list",
                "-t",
                "snapshot",
                "-o",
                "name",
                "-S",
                "creation",
                "-H",
                "-d",
                "1",
                ds,
            ],
            check=False,
        )
        if snaps:
            latest_snap = snaps.splitlines()[0]
            print(f"  -> Rolling back to safe snapshot: {latest_snap}")
            run_zfs(["rollback", "-r", latest_snap])

        print(f"  -> Renaming to: {target_ds}")
        run_zfs(["rename", ds, target_ds])


def promote_openebs():
    wait_for_k8s()
    wait_for_flux()

    try:
        kusts = crd_api.list_cluster_custom_object(
            FLUX_GROUP, FLUX_VERSION, FLUX_PLURAL
        )
        kust_items = kusts.get("items", [])
    except ApiException as e:
        print(f"Warning: Could not list Flux Kustomizations: {e}")
        kust_items = []

    for item in kust_items:
        ns = item["metadata"]["namespace"]
        name = item["metadata"]["name"]
        print(f"  -> Suspending Flux Kustomization: {ns}/{name}")
        crd_api.patch_namespaced_custom_object(
            FLUX_GROUP, FLUX_VERSION, ns, FLUX_PLURAL, name, {"spec": {"suspend": True}}
        )

    out = run_zfs(["list", "-H", "-o", "name", "-r", PASSIVE_OPENEBS], check=False)
    backup_datasets = [
        line for line in out.splitlines() if line and line != PASSIVE_OPENEBS
    ]

    claimed_pvcs = {}
    valid_datasets = []

    for b_ds in backup_datasets:
        ns = run_zfs(
            ["get", "-H", "-p", "-o", "value", "k8s:namespace", b_ds], check=False
        )
        pvc_name = run_zfs(
            ["get", "-H", "-p", "-o", "value", "k8s:pvc", b_ds], check=False
        )

        if ns in ["-", ""] or pvc_name in ["-", ""]:
            continue

        pvc_identifier = f"{ns}/{pvc_name}"

        if pvc_identifier in claimed_pvcs:
            conflicting_ds = claimed_pvcs[pvc_identifier]
            print(f"  -> Dataset 1: {conflicting_ds}")
            print(f"  -> Dataset 2: {b_ds}")
            print("  -> Halting DR sequence BEFORE making any changes to the cluster.")
            print(
                "  -> Please manually destroy the orphaned/stale dataset and run the playbook again."
            )
            sys.exit(1)

        claimed_pvcs[pvc_identifier] = b_ds
        valid_datasets.append({"ds": b_ds, "ns": ns, "pvc": pvc_name})

    migration_map = {}
    saved_manifests = {}

    for item in valid_datasets:
        b_ds = item["ds"]
        ns = item["ns"]
        pvc_name = item["pvc"]

        migration_map[b_ds] = {"ns": ns, "pvc": pvc_name}
        print(
            f"  -> Discovered passive backup: {ns}/{pvc_name}. Waiting for dummy PVC to bind..."
        )

        dummy_pv_name = None
        max_pvc_wait_loops = 60

        for i in range(max_pvc_wait_loops):
            print(f"Trying to map {b_ds}")
            try:
                pvc_obj = core_api.read_namespaced_persistent_volume_claim(pvc_name, ns)
                if pvc_obj.status.phase == "Bound":
                    dummy_pv_name = pvc_obj.spec.volume_name
                    break
            except ApiException:
                pass

            time.sleep(2)
        else:
            print(f"  -> WARNING: Timed out waiting for PVC {ns}/{pvc_name} to bind.")
            print(f"  -> Skipping dataset {b_ds} to prevent DR deadlock.")
            del migration_map[b_ds]
            continue

        print(f"  -> Capturing template from dummy PV {dummy_pv_name}")

        pv_obj = core_api.read_persistent_volume(dummy_pv_name)
        zv_obj = crd_api.get_namespaced_custom_object(
            ZFS_GROUP, ZFS_VERSION, "openebs", ZFS_PLURAL, dummy_pv_name
        )

        saved_manifests[b_ds] = {
            "pv": clean_manifest(pv_obj),
            "zv": clean_manifest(zv_obj),
            "pvc": clean_manifest(pvc_obj),
            "dummy_pv": dummy_pv_name,
        }

    pending_deletions = {}
    for b_ds, data in migration_map.items():
        ns = data["ns"]
        pvc_name = data["pvc"]
        dummy_pv = saved_manifests[b_ds]["dummy_pv"]
        dummy_ds = f"{ACTIVE_OPENEBS}/{dummy_pv}"

        print(f"  -> Deleting dummy state for {ns}/{pvc_name}")
        try:
            core_api.delete_namespaced_persistent_volume_claim(pvc_name, ns)
        except ApiException:
            pass

        try:
            crd_api.delete_namespaced_custom_object(
                ZFS_GROUP, ZFS_VERSION, "openebs", ZFS_PLURAL, dummy_pv
            )
        except ApiException:
            pass

        try:
            core_api.delete_persistent_volume(dummy_pv)
        except ApiException:
            pass
        pending_deletions[dummy_pv] = dummy_ds

    max_delete_wait = 60

    print("  -> Waiting for OpenEBS CSI driver to finalize deletions...")
    for i in range(max_delete_wait):
        for dummy_pv, dummy_ds in list(pending_deletions.items()):
            try:
                core_api.read_persistent_volume(dummy_pv)
                continue
            except ApiException as e:
                if e.status != 404:
                    continue

            try:
                crd_api.get_namespaced_custom_object(
                    ZFS_GROUP, ZFS_VERSION, "openebs", ZFS_PLURAL, dummy_pv
                )
                continue
            except ApiException as e:
                if e.status != 404:
                    continue
            if run_zfs(["list", dummy_ds], check=False):
                continue
            print(f"  -> Verified explicit cleanup complete for {dummy_pv}")
            del pending_deletions[dummy_pv]

        if not pending_deletions:
            break

        time.sleep(2)
    else:
        print(
            f"\nCRITICAL ERROR: Timed out waiting for OpenEBS to clean up {len(pending_deletions)} dummy objects."
        )
        print("  -> The following objects are stuck terminating:")
        for pv in pending_deletions.keys():
            print(f"     - {pv}")
        sys.exit(1)

    if not run_zfs(["list", ACTIVE_OPENEBS], check=False):
        run_zfs(["create", "-p", ACTIVE_OPENEBS])

    for b_ds, data in migration_map.items():
        ns = data["ns"]
        pvc_name = data["pvc"]
        vol_name = b_ds.split("/")[-1]
        target_ds = f"{ACTIVE_OPENEBS}/{vol_name}"

        print(f"----------------------------------------------------")
        print(f"Importing dataset for {ns}/{pvc_name} to {target_ds}")

        run_zfs(["rename", b_ds, target_ds])
        run_zfs(["set", f"k8s:namespace={ns}", target_ds])
        run_zfs(["set", f"k8s:pvc={pvc_name}", target_ds])
        run_zfs(["set", "mountpoint=legacy", target_ds])

        print("  -> Recreating mapped Kubernetes objects via API...")
        manifests = saved_manifests[b_ds]

        manifests["pv"]["metadata"]["name"] = vol_name
        manifests["pv"]["spec"]["csi"]["volumeHandle"] = vol_name
        manifests["zv"]["metadata"]["name"] = vol_name
        manifests["pvc"]["spec"]["volumeName"] = vol_name

        core_api.create_persistent_volume(body=manifests["pv"])
        crd_api.create_namespaced_custom_object(
            ZFS_GROUP, ZFS_VERSION, "openebs", ZFS_PLURAL, body=manifests["zv"]
        )
        core_api.create_namespaced_persistent_volume_claim(
            namespace=ns, body=manifests["pvc"]
        )

    for item in kust_items:
        ns = item["metadata"]["namespace"]
        name = item["metadata"]["name"]
        print(f"  -> Resuming Flux Kustomization: {ns}/{name}")
        crd_api.patch_namespaced_custom_object(
            FLUX_GROUP,
            FLUX_VERSION,
            ns,
            FLUX_PLURAL,
            name,
            {"spec": {"suspend": False}},
        )


if __name__ == "__main__":
    promote_non_openebs()
    promote_openebs()
    print("Done.")
