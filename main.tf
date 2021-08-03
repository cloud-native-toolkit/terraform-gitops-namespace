locals {
  layer = "infrastructure"
  layer_config = var.gitops_config[local.layer]
  application_branch = "main"
  config_namespace = "default"
  yaml_dir = "${path.cwd}/.tmp/namespace-${var.name}"
}

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.yaml_dir}' '${var.name}'"
  }
}

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml]

  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-gitops.sh 'namespace-${var.name}' '${local.yaml_dir}' 'namespaces' '${local.application_branch}' '${local.config_namespace}' '${var.name}'"

    environment = {
      GIT_CREDENTIALS = jsonencode(var.git_credentials)
      GITOPS_CONFIG = jsonencode(local.layer_config)
    }
  }
}

module "rbac" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-rbac.git?ref=v1.4.0"
  depends_on = [null_resource.setup_gitops]

  gitops_config             = var.gitops_config
  git_credentials           = var.git_credentials
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

module "ci_config" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-ci-namespace.git?ref=v1.2.1"
  depends_on = [module.rbac]

  gitops_config             = var.gitops_config
  git_credentials           = var.git_credentials
  namespace                 = var.name
  provision                 = var.ci
}
