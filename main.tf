locals {
  application_branch = "main"
  create_operator_group = var.name != "openshift-operators" && var.create_operator_group
  layer = "infrastructure"
  type = "base"
}

resource gitops_namespace ns {

  name = var.name
  create_operator_group = local.create_operator_group
  argocd_namespace = var.argocd_namespace
  dev_namespace = var.ci
  server_name = var.server_name
  branch = local.application_branch
  config = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}
