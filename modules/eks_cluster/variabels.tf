variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string

}

variable "eks_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  #   default     = "1.27"

}


variable "eks_subnet_ids" {
  description = "A list of subnet IDs for the EKS cluster"
  type        = list(string)

}

variable "environment" {
  description = "The environment for the EKS cluster (e.g., dev, prod)"
  type        = string

}

variable "node_groups" {
    description = "A map of node group configurations"
    type = map(object({
        node_group_name = string
        instance_type = list(string)
        capacity_type  = string
        desired_size  = number
        max_size      = number
        min_size      = number
        disk_size     = number
        ami_type      = string
        taint = optional(list(object({
            key    = string
            value  = string
            effect = string
        })), [])
        labels = optional(map(string), {})
    }))
  
}