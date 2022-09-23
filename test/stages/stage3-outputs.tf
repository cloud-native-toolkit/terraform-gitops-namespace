
resource local_file write_outputs {
  filename = "gitops-output.json"

  content = jsonencode({
    name        = module.gitops_namespace.name
    branch      = module.gitops_namespace.branch
    namespace   = module.gitops_namespace.name
    server_name = module.gitops_namespace.server_name
    layer       = module.gitops_namespace.layer
    layer_dir   = module.gitops_namespace.layer == "infrastructure" ? "1-infrastructure" : (module.gitops_namespace.layer == "services" ? "2-services" : "3-applications")
    type        = module.gitops_namespace.type
  })
}
