terraform {
  backend "s3" {
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    endpoint                    = "https://ams3.digitaloceanspaces.com"
    region                      = "us-east-1"
    bucket                      = "tfstate-aura"
    key                         = "cluster-ghost.tfstate"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  
  config = {
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    endpoint                    = "https://ams3.digitaloceanspaces.com"
    region                      = "us-east-1"
    bucket                      = "tfstate-aura"
    key                         = "cluster.tfstate"
  }
}

provider "kubernetes" {
  load_config_file = false
  host  = data.terraform_remote_state.cluster.outputs.cluster_access.endpoint
  token = data.terraform_remote_state.cluster.outputs.cluster_access.token
  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.cluster.outputs.cluster_access.ca_cert
  )
}

provider "helm" {
  load_config_file = false
  host  = data.terraform_remote_state.cluster.outputs.cluster_access.endpoint
  token = data.terraform_remote_state.cluster.outputs.cluster_access.token
  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.cluster.outputs.cluster_access.ca_cert
  )
}

provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}