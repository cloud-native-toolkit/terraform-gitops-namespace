locals {
  layer = "infrastructure"
  config_project = var.config_projects[local.layer]
  application_branch = "main"
  config_namespace = "default"
}

resource null_resource setup_namespace {
  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-namespace.sh '${var.application_repo}' '${var.application_paths[local.layer]}' '${var.name}'"

    environment = {
      TOKEN = var.application_token
    }
  }
}

resource null_resource setup_argocd {
  depends_on = [null_resource.setup_namespace]
  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-argocd.sh '${var.config_repo}' '${var.config_paths[local.layer]}' '${local.config_project}' '${var.application_repo}' '${var.application_paths[local.layer]}/namespaces' '${local.config_namespace}' '${local.application_branch}'"

    environment = {
      TOKEN = var.config_token
    }
  }
}
