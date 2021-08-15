locals {
  bin_dir  = module.setup_clis.bin_dir
  yaml_dir = "${path.cwd}/.tmp/namespace-${var.name}"
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.yaml_dir}' '${var.name}'"

    environment = {
      BIN_DIR = local.bin_dir
    }
  }
}

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml]

  provisioner "local-exec" {
    command = "${local.bin_dir}/igc gitops-namespace ${var.name} --contentDir ${local.yaml_dir} --serverName ${var.server_name}"

    environment = {
      GIT_CREDENTIALS = yamlencode(var.git_credentials)
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }
}

module "rbac" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-rbac.git?ref=v1.6.1"
  depends_on = [null_resource.setup_gitops]

  gitops_config             = var.gitops_config
  git_credentials           = var.git_credentials
  service_account_namespace = var.argocd_namespace
  service_account_name      = var.argocd_service_account
  namespace                 = var.name
  server_name               = var.server_name
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
  source = "github.com/cloud-native-toolkit/terraform-gitops-ci-namespace.git?ref=v1.4.2"
  depends_on = [module.rbac]

  gitops_config   = var.gitops_config
  git_credentials = var.git_credentials
  namespace       = var.name
  provision       = var.ci
  server_name     = var.server_name
}
