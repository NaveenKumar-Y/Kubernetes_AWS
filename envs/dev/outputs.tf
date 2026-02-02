# output "cluster_endpoint" {
#   description = "The endpoint of the EKS cluster"
#   value       = module.aws_eks_cluster.cluster_endpoint
  
# }

output "argocd_initial_admin_password" {
    description = "Initial admin password for Argo CD"
    value       = module.argocd.intial_argocd_secret
    # sensitive   = true
  
}

# output "argocd_server_url" {
#     description = "server url"
#     value       = module.argocd.argocd_server_host
  
# }

# output "argocd_hostname" {
#     description = "Argo CD Server Hostname"
#     value       = data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname
  
# }