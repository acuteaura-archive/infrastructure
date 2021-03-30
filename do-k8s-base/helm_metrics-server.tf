resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "metrics-server"
  version    = "2.11.2"
  namespace = "kube-system"

  set {
    name = "args[0]"
    value = "--kubelet-insecure-tls"
  }

  set {
    name = "args[1]"
    value = "--kubelet-preferred-address-types=InternalIP"
  }
}