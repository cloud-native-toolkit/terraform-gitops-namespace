
variable "gitops_config" {
  type        = object({
    boostrap = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
    })
    infrastructure = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    services = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    applications = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
  })
  description = "Config information regarding the gitops repo structure"
}

variable "git_credentials" {
  type = list(object({
    repo = string
    url = string
    username = string
    token = string
  }))
  description = "The credentials for the gitops repo(s)"
  sensitive   = true
}

variable "name" {
  type        = string
  description = "The value that should be used for the namespace"
}

variable "ci" {
  type        = bool
  description = "Flag indicating that this namespace will be used for development (e.g. configmaps and secrets)"
  default     = false
}

variable "server_name" {
  type        = string
  description = "The name of the server"
  default     = "default"
}

variable "create_operator_group" {
  type        = bool
  description = "Flag indicating that an operator group should be created in the namespace"
  default     = true
}

variable "argocd_namespace" {
  type        = string
  description = "The namespace where argocd has been deployed"
  default     = "openshift-gitops"
}

variable "branch" {
  type        = string
  description = "The branch in the gitops repo where the resources should be placed"
  default     = "main"
}
