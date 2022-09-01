locals {
  bin_dir  = module.setup_clis.bin_dir
  yaml_dir = "${path.cwd}/.tmp/namespace-${var.name}"
  application_branch = "main"
  create_operator_group = var.name != "openshift-operators" && var.create_operator_group
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.yaml_dir}' '${var.name}' '${local.create_operator_group}' '${var.argocd_namespace}'"

    environment = {
      BIN_DIR = local.bin_dir
    }
  }
}

resource gitops_namespace ns {
  depends_on = [null_resource.create_yaml]

  name = var.name
  content_dir = local.yaml_dir
  server_name = var.server_name
  branch = local.application_branch
  config = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}

module "ci_config" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-ci-namespace.git?ref=v1.6.0"
  depends_on = [gitops_namespace.ns]

  gitops_config   = var.gitops_config
  git_credentials = var.git_credentials
  namespace       = var.name
  provision       = var.ci
  server_name     = var.server_name
}
