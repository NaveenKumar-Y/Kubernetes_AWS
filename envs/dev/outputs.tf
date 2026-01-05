# output "cluster_endpoint" {
#   description = "The endpoint of the EKS cluster"
#   value       = module.aws_eks_cluster.cluster_endpoint
  
# }

output "argocd_initial_admin_password" {
    description = "Initial admin password for Argo CD"
    value       = module.argocd.intial_argocd_secret
    # sensitive   = true
  
}