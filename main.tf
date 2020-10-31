terraform {
  backend "remote" {
    organization = "cusk"

    workspaces {
      name = "learn-terraform-pipelines-consul"
    }
  }
}

data "terraform_remote_state" "cluster" {
  backend = "remote"
  config = {
    organization = var.organization
    workspaces = {
      name = var.cluster_workspace
    }
  }
}

# resource "local_file" "kube_config" {
#   filename = "${path.module}/kube_config.yaml"
#   sensitive_content = data.terraform_remote_state.cluster.outputs.kube_config
#   # content = data.terraform_remote_state.cluster.outputs.kube_config
#   file_permission = "0666"

# }

# output "kubeconfig_filename" {
#   value = local_file.kube_config.filename
# }

# output "kubeconfig_content" {
#   value = local_file.kube_config.content
# }

provider "kubernetes" {
  version = "~> 1.13.3"
  # config_path = local_file.kube_config.filename
  load_config_file       = false
  host                   = data.terraform_remote_state.cluster.outputs.host
  # username               = data.terraform_remote_state.cluster.outputs.username
  # password               = data.terraform_remote_state.cluster.outputs.password
  token                  = data.terraform_remote_state.cluster.outputs.token
  cluster_ca_certificate = data.terraform_remote_state.cluster.outputs.cluster_ca_certificate
}

provider "helm" {
  version = "~> 1.0"
  kubernetes {
    # config_path = local_file.kube_config.filename
    load_config_file       = false
    host                   = data.terraform_remote_state.cluster.outputs.host
    # username               = data.terraform_remote_state.cluster.outputs.username
    # password               = data.terraform_remote_state.cluster.outputs.password
    token                  = data.terraform_remote_state.cluster.outputs.token
    cluster_ca_certificate = data.terraform_remote_state.cluster.outputs.cluster_ca_certificate
  }
}
