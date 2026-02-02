# 1. Namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      name = "argocd"
    }
  }
}

# 2. Argo CD Helm release
resource "helm_release" "argocd" {

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = var.argocd_helm_chart_version

  values = [yamlencode({
    server = {
      service = {
        type = "NodePort"  # ideally we have to use LB or ingress
        # annotations = {
        #   # Use the AWS LB Controller to create an NLB
        #   "service.beta.kubernetes.io/aws-load-balancer-type"            = "external"
        #   "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
        #   "service.beta.kubernetes.io/aws-load-balancer-scheme"         = "internet-facing"
        # }
      }
      insecure = true  # for practice, integrate with cert
    }
    # configs = {
    #   params = [
    #     "server.insecure=true"
    #   ]
    # }

    configs = {
      params = {
        create = false 
      }
      secret = {
        create = false
      }
    }

    dex = {
        enabled = false
    }
    resource = {
      limits = {
        cpu    = "500m"
        memory = "512Mi"
      }
      requests = {
        cpu    = "250m"
        memory = "256Mi"
      }
    }
  })]

  wait = false


}

# resource "null_resource" "access_argocd_server" {
#   depends_on = [ helm_release.argocd ]

#   provisioner "local-exec" {
#     command = "aws eks update-kubeconfig --name ${var.cluster_name}"
#   }

#   provisioner "local-exec" {
#     command = "kubectl port-forward deployment/argocd-server -n argocd  8080:80"
#   }
  
# }

# data "kubernetes_service" "argocd_server" {
#   metadata {
#     name      = "argocd-server"
#     namespace = kubernetes_namespace.argocd.metadata[0].name
#   }

#   depends_on = [ helm_release.argocd ]
# }


data "kubernetes_secret_v1" "argocd_initial_admin_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  depends_on = [ helm_release.argocd ]
}



# output "argocd_admin_password_plaintext" {
#   description = "Base64 decoded ArgoCD password (copy-paste ready)"
#   value       = nonsensitive(base64decode(data.kubernetes_secret_v1.argocd_initial_admin_secret.data["password"]))
#   sensitive   = true
# }


