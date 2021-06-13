
variable "config_repo" {
  type        = string
  description = "The repo that contains the argocd configuration"
}

variable "config_token" {
  type        = string
  description = "The token for the config repo"
}

variable "config_paths" {
  description = "The paths in the config repo"
  type        = object({
    infrastructure = string
    services       = string
    applications   = string
  })
}

variable "application_repo" {
  type        = string
  description = "The repo that contains the application configuration"
}

variable "application_token" {
  type        = string
  description = "The token for the application repo"
}

variable "application_paths" {
  description = "The paths in the application repo"
  type        = object({
    infrastructure = string
    services       = string
    applications   = string
  })
}

variable "name" {
  type        = string
  description = "The value that should be used for the namespace"
}
