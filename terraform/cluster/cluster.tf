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

provider "cloudflare" {
  version = "~> 2.0"
}

locals {
  default_node_pool = {
    size = "s-2vcpu-4gb"
    node_count = 2
  }
}

resource "digitalocean_kubernetes_cluster" "cluster" {
  name    = "infrastructure-${var.env}-cluster"
  region  = "ams3"

  version = "1.18.8-do.1"

  node_pool {
    name       = "${var.env}-${local.default_node_pool.size}"
    size       = local.default_node_pool.size
    node_count = local.default_node_pool.node_count
  }
}

output "cluster_access" {
  value = {
    endpoint: digitalocean_kubernetes_cluster.cluster.endpoint
    token: digitalocean_kubernetes_cluster.cluster.kube_config[0].token
    ca_cert: digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate
  }
}