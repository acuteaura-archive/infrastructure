resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager-system"
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace = kubernetes_namespace.cert_manager.metadata[0].name

  set {
    name = "installCRDs"
    value = "true"
  }
}

# resource "kubernetes_manifest" "issuer_acme" {
#     provider = kubernetes-alpha
    
#     manifest = {
#         apiVersion = "cert-manager.io/v1"
#         kind = "ClusterIssuer"
#         metadata = {
#             name = "letsencrypt-staging"
#         }
#         spec = {
#             acme = {
#                 email = "aurelia@schittler.dev"
#                 server = "https://acme-staging-v02.api.letsencrypt.org/directory"
#                 privateKeySecretRef = {
#                     name = "issuer-letsencrypt-staging-keys"
#                 }
#             }
#         }
#         solvers = [
#             {
#                 dns01 = {
#                     cloudflare = {
#                         email = "aurelia@schittler.dev"
#                         apiTokenSecretRef = {
#                             name = "issuer-letsencrypt-staging-cloudflare"
#                             key = "api-token"
#                         }
#                     }
#                 }
#             }
#         ]
#     }

#     depends_on = [helm_release.cert_manager]
# }