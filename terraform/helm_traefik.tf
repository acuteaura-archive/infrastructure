resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = "9.4.3"
  
  set {
    name = "deployment.replicas"
    value = "2"
  }
}

data "kubernetes_service" "traefik" {
  metadata {
    name = "traefik"
    namespace = "default"
  }

  depends_on = [helm_release.traefik]
}

output "ingress_ip" {
  value = data.kubernetes_service.traefik.load_balancer_ingress[0].ip
}