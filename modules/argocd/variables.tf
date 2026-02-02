variable "argocd_helm_chart_version" {
  type        = string
  description = "The version of the Argo CD Helm chart to deploy."
  default     = "7.6.2"
  
}

variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster where Argo CD will be deployed." 
  
}