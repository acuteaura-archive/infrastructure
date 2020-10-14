resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "metrics-server"
  version    = "2.11.2"
}