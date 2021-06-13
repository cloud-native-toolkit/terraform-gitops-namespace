output "name" {
  value       = var.name
  description = "Namespace name"
  depends_on  = [
    null_resource.setup_argocd,
    null_resource.setup_namespace
  ]
}
