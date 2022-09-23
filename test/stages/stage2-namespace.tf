module "gitops_namespace" {
  source = "./module"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  name = local.test_namespace
  ci = true
}
