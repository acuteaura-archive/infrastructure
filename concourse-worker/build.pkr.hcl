variable "hcloud_token" {
    default = env("CONCOURSE_HCLOUD_TOKEN")
}

source "hcloud" "hel1" {
    image = "fedora-33"
    location = "hel1"
    server_type = "cx11"
    ssh_username = "root"
    snapshot_name = "{{build_name}}-${ formatdate("YYYY-MM-DD-hh-mm-ssZ", timestamp()) }"
    token = var.hcloud_token
    user_data_file = "${path.root}/files/user-data"
}

build {
    name = "concourse-worker"

    provisioner "ansible" {
      playbook_file = "${path.root}/playbook.yml"
      user = "root"
    }

    source "hcloud.hel1" {}
}