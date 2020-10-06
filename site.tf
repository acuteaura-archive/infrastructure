terraform {
  backend "s3" {
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    endpoint                    = "https://ams3.digitaloceanspaces.com"
    region                      = "us-east-1" // needed
    bucket                      = "tfstate-aura" // name of your space
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