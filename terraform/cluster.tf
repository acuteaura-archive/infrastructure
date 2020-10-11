terraform {
  backend "s3" {
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    endpoint                    = "https://ams3.digitaloceanspaces.com"
    region                      = "us-east-1"
    bucket                      = "tfstate-aura"
    key                         = "infrastructure.tfstate"
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

resource "digitalocean_kubernetes_cluster" "cluster" {
  name    = "infrastructure-${var.env}-cluster"
  region  = "ams3"

  version = "1.18.8-do.1"

  node_pool {
    name       = "${var.env}-s-1vcpu-2gb"
    size       = "s-1vcpu-2gb"
    node_count = 1
  }
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "metrics-server"
  version    = "2.11.2"
}

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

output "cluster_access" {
  value = {
    endpoint: digitalocean_kubernetes_cluster.cluster.endpoint
    token: digitalocean_kubernetes_cluster.cluster.kube_config[0].token
    ca_cert: digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate
  }
}

output "ingress_ip" {
  value = data.kubernetes_service.traefik.load_balancer_ingress[0].ip
}