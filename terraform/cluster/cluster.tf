locals {
  default_node_pool = {
    size = "s-1vcpu-2gb"
    node_count = 2
  }
}

resource "digitalocean_kubernetes_cluster" "cluster" {
  name    = "infrastructure-${var.env}-cluster"
  region  = "ams3"

  version = "1.19.3-do.0"

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