resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = "9.4.3"
  namespace = "kube-system"
  
  set {
    name = "deployment.replicas"
    value = "2"
  }
}

data "kubernetes_service" "traefik" {
  metadata {
    name = "traefik"
    namespace = "kube-system"
  }

  depends_on = [helm_release.traefik]
}

output "ingress_ip" {
  value = data.kubernetes_service.traefik.load_balancer_ingress[0].ip
}

resource "cloudflare_record" "ingress" {
  zone_id = "2d0c6d8925e96896c7fd5594e864b5c8"
  name    = "ingress-${var.env}"
  value   = data.kubernetes_service.traefik.load_balancer_ingress[0].ip
  type    = "A"
  ttl     = 3600
}