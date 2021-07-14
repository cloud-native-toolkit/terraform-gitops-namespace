output "name" {
  value       = var.name
  description = "Namespace name"
  depends_on  = [
    module.dev_config
  ]
}
