resource "kubernetes_namespace" "linkerd" {
  metadata {
    name = "linkerd-system"
  }
}

resource "helm_release" "linkerd" {
  name       = "linkerd"
  repository = "https://helm.linkerd.io/stable"
  chart      = "linkerd2"
  namespace = kubernetes_namespace.linkerd.metadata[0].name

  set {
    name = "global.identityTrustAnchorsPEM"
    value = file("linkerd-ca/ca.crt")
  }

  set {
    name = "identity.issuer.tls.crtPEM"
    value = file("linkerd-ca/issuer.crt")
  }

  set {
    name = "identity.issuer.tls.keyPEM"
    value = file("linkerd-ca/issuer.key")
  }

  set {
    name = "identity.issuer.crtExpiry"
    value = file("linkerd-ca/exp.tmp")
  }
}