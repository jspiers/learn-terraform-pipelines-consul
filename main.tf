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

resource "local_file" "kube_config" {
  filename = "kube_config.yaml"
  sensitive_content  = data.terraform_remote_state.cluster.outputs.kube_config
  file_permission = "0666"
}

provider "kubernetes" {
  version = "~> 1.11"
  config_path = local_file.kube_config.filename
}

provider "helm" {
  version = "~> 1.0"
  kubernetes {
    config_path = local_file.kube_config.filename
  }
}
