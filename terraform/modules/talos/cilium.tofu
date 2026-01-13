#resource "kubernetes_manifest" "gateway_api_standard" {
#  manifest = yamldecode(file("https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml"))
#
#  depends_on = [
#    talos_cluster_kubeconfig.this
#  ]
#
#  timeouts {
#    create = "10m"
#    update = "10m"
#    delete = "30s"
#  }
#}

data "talos_cluster_health" "wait_for_cluster" {
  endpoints              = [var.kubernetes_endpoint]
  client_configuration   = talos_machine_secrets.this.client_configuration
  control_plane_nodes    = [var.ip]
  skip_kubernetes_checks = true

  depends_on = [
    talos_cluster_kubeconfig.this
  ]
}

resource "helm_release" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = "1.18.5"
  namespace  = "kube-system"

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

  #depends_on = [
  #  kubernetes_manifest.gateway_api_standard
  #]
  depends_on = [
    data.talos_cluster_health.wait_for_cluster
  ]
  timeout = 600 # wait up to 10 minutes
}
