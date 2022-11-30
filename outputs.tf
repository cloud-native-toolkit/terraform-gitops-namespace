output "name" {
  value       = var.name
  description = "Namespace name"
  depends_on  = [gitops_namespace.ns]
}
