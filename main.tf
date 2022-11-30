locals {
  tmp_dir = ".tmp/namespace-${var.name}"
  create_operator_group = var.name != "openshift-operators" && var.create_operator_group
}

resource gitops_namespace ns {
  name = var.name
  create_operator_group = local.create_operator_group
  argocd_namespace = var.argocd_namespace
  dev_namespace = var.ci
  server_name = var.server_name
  branch = var.branch
  config = var.gitops_config
  credentials = var.git_credentials
  tmp_dir = local.tmp_dir
}
