output "intial_argocd_secret" {
    description = "Initial admin password for Argo CD"
    value       = nonsensitive(data.kubernetes_secret_v1.argocd_initial_admin_secret.data["password"])
    # sensitive   = true
}

# output "argocd_server_host" {
#     description = "Argo CD Server URL"
#     value       = data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname
# }
  
