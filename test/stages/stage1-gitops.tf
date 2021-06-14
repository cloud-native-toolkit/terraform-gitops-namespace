module "gitops" {
  source = "github.com/cloud-native-toolkit/terraform-tools-gitops"

  host = var.git_host
  type = var.git_type
  org  = var.git_org
  repo = var.git_repo
  token = var.git_token
  gitops_namespace = var.gitops_namespace
}