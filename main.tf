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

module "rbac" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-rbac.git?ref=v1.3.0"
  depends_on = [null_resource.setup_argocd]

  config_repo               = var.config_repo
  config_token              = var.config_token
  config_paths              = var.config_paths
  config_projects           = var.config_projects
  application_repo          = var.application_repo
  application_token         = var.application_token
  application_paths         = var.application_paths
  service_account_namespace = var.argocd_namespace
  service_account_name      = var.argocd_service_account
  namespace                 = var.name
  rules = [{
    apiGroups = ["apps"]
    resources = ["deployments", "statefulset"]
    verbs = ["*"]
  }, {
    apiGroups = [""]
    resources = ["secrets", "configmaps", "serviceaccounts", "services"]
    verbs = ["*"]
  }, {
    apiGroups = ["batch"]
    resources = ["cronjobs","jobs"]
    verbs = ["*"]
  }, {
    apiGroups = ["route.openshift.io"]
    resources = ["routes"]
    verbs = ["*"]
  }]
}

module "dev_config" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-dev-namespace.git?ref=v1.1.0"
  depends_on = [null_resource.setup_argocd]

  config_repo               = var.config_repo
  config_token              = var.config_token
  config_paths              = var.config_paths
  config_projects           = var.config_projects
  application_repo          = var.application_repo
  application_token         = var.application_token
  application_paths         = var.application_paths
  namespace                 = var.name
  provision                 = var.dev
}
