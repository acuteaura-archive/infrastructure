terraform {
  backend "s3" {
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    endpoint                    = "https://ams3.digitaloceanspaces.com"
    region                      = "us-east-1"
    bucket                      = "tfstate-aura"
    key                         = "cluster.tfstate"
  }
}

variable "env" {
  type = string
  default = "prod"
}

provider "digitalocean" {}

provider "kubernetes" {
  load_config_file = false
  host  = digitalocean_kubernetes_cluster.cluster.endpoint
  token = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate
  )
}

# provider "kubernetes-alpha" {
#   host  = digitalocean_kubernetes_cluster.cluster.endpoint
#   token = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
#   cluster_ca_certificate = base64decode(
#     digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate
#   )
# }

provider "helm" {
  kubernetes {
    load_config_file = false
    host     =  digitalocean_kubernetes_cluster.cluster.endpoint
    token = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(
      digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate
    )
  }
}

provider "cloudflare" {
  version = "~> 2.0"
}