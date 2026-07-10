import os
import pytest
from unittest.mock import patch, call

# 1. Mock Environment Variables BEFORE importing
mock_env = {
    "ZFS_PASSIVE_DATASET": "tank/passive",
    "ZFS_ACTIVE_DATASET": "tank/active",
    "ZFS_PASSIVE_OPENEBS_DATASET": "tank/passive/openebs",
    "ZFS_ACTIVE_OPENEBS_DATASET": "tank/active/openebs",
    "RKE2_KUBECONFIG_PATH": "/dev/null",
}

# 2. Mock the Kubernetes config loader so it doesn't try to read a real cluster on import
with patch.dict(os.environ, mock_env), patch("kubernetes.config.load_kube_config"):
    import dr_failover


# ==========================================
# TESTS
# ==========================================
@patch("dr_failover.run_zfs")
def test_skips_when_only_openebs_exists(mock_run_zfs):
    def zfs_mock_responses(cmd, check=True):
        if cmd == ["list", dr_failover.ACTIVE_ROOT]:
            return ""
        if cmd == ["list", "-H", "-o", "name", "-d", "1", dr_failover.PASSIVE_ROOT]:
            return dr_failover.PASSIVE_OPENEBS
        return ""

    mock_run_zfs.side_effect = zfs_mock_responses
    dr_failover.promote_non_openebs()

    called_commands = [call_args[0][0] for call_args in mock_run_zfs.call_args_list]
    assert [
        "list",
        "-H",
        "-o",
        "name",
        "-d",
        "1",
        dr_failover.PASSIVE_ROOT,
    ] in called_commands

    for cmd in called_commands:
        assert cmd[0] != "rename"
        assert cmd[0] != "rollback"


@patch("dr_failover.run_zfs")
def test_processes_custom_datasets_but_skips_openebs(mock_run_zfs):
    def zfs_mock_responses(cmd, check=True):
        if cmd == ["list", dr_failover.ACTIVE_ROOT]:
            return ""
        if cmd == ["list", "-H", "-o", "name", "-d", "1", dr_failover.PASSIVE_ROOT]:
            return (
                f"{dr_failover.PASSIVE_OPENEBS}\n{dr_failover.PASSIVE_ROOT}/my-database"
            )
        if cmd == [
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
            f"{dr_failover.PASSIVE_ROOT}/my-database",
        ]:
            return f"{dr_failover.PASSIVE_ROOT}/my-database@snap1"
        return ""

    mock_run_zfs.side_effect = zfs_mock_responses
    dr_failover.promote_non_openebs()

    called_commands = [call_args[0][0] for call_args in mock_run_zfs.call_args_list]
    assert [
        "rollback",
        "-r",
        f"{dr_failover.PASSIVE_ROOT}/my-database@snap1",
    ] in called_commands
    assert [
        "rename",
        f"{dr_failover.PASSIVE_ROOT}/my-database",
        f"{dr_failover.ACTIVE_ROOT}/my-database",
    ] in called_commands

    for cmd in called_commands:
        if cmd[0] in ["rename", "rollback"]:
            assert "openebs" not in cmd[-1]
