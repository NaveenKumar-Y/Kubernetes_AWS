variable "environment" {
  description = "The environment for the EKS cluster (e.g., dev, prod)"
  type        = string

}

variable "node_groups" {
  description = "A map of node group configurations"
  type = map(object({
    node_group_name = string
    instance_type   = list(string)
    capacity_type   = string
    desired_size    = number
    max_size        = number
    min_size        = number
    disk_size       = number
    ami_type        = string
    taint = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    labels = optional(map(string), {})
  }))

}

# variable "github_pat_token" {
  
# }

# variable "GH_REPO_URL" {
#   default = "https://github.com/NaveenKumar-Y/Docker/"
# }

variable "argocd_username" {
  type        = string
  description = "Argo CD username"
  default     = "admin"
  
}