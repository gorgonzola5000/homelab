data "helm_template" "cilium" {
  namespace    = "kube-system"
  name         = "cilium"
  repository   = "https://helm.cilium.io"
  chart        = "cilium"
  version      = "1.18.5"
  kube_version = var.kubernetes_version
  api_versions = [
    "gateway.networking.k8s.io/v1/GatewayClass"
  ]

  set = [
    {
      name  = "ipam.mode"
      value = "kubernetes"
    },
    {
      name  = "kubeProxyReplacement"
      value = "true"
    },
    {
      name  = "securityContext.capabilities.ciliumAgent"
      value = "{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}"
    },
    {
      name  = "securityContext.capabilities.cleanCiliumState"
      value = "{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}"
    },
    {
      name  = "cgroup.autoMount.enabled"
      value = "false"
    },
    {
      name  = "cgroup.hostRoot"
      value = "/sys/fs/cgroup"
    },
    {
      name  = "k8sServiceHost"
      value = "localhost"
    },
    {
      name  = "k8sServicePort"
      value = "7445"
    },
    # gatewayAPI
    {
      name  = "gatewayAPI.enabled"
      value = "true"
    },
    {
      name  = "gatewayAPI.enableAlpn"
      value = "true"
    },
    {
      name  = "gatewayAPI.enableAppProtocol"
      value = "true"
    },
    # single node
    {
      name  = "operator.replicas"
      value = "1"
    },
    # hostNetwork
    {
      name  = "gatewayAPI.hostNetwork.enabled"
      value = "true"
    },
    # bind to privileged port
    {
      name  = "envoy.securityContext.capabilities.keepCapNetBindService"
      value = "true"
    },
    {
      name  = "envoy.securityContext.capabilities.envoy"
      value = "{NET_BIND_SERVICE,NET_ADMIN,BPG,PERFORM,SYS_ADMIN}"
    }
  ]
}
