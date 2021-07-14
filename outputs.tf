output "name" {
  value       = var.name
  description = "Namespace name"
  depends_on  = [
    null_resource.setup_gitops
  ]
}
