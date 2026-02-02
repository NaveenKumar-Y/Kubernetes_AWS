# Configure the AWS Provider
provider "aws" {
  # Configuration options
  region = "us-east-1"
  profile = "default"
}

# data "kubernetes_cluster_endpoint" "this" {
#   depends_on = [module.aws_eks_cluster]
# }


# Force provider data refresh
# resource "null_resource" "provider_refresh" {
#   triggers = {
#     cluster_endpoint = data.aws_eks_cluster.this.endpoint
#     cluster_name     = module.aws_eks_cluster.cluster_name
#   }
  
#   depends_on = [module.aws_eks_cluster]
# }


data "aws_eks_cluster" "this" {
  depends_on = [module.aws_eks_cluster]
  name = module.aws_eks_cluster.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  depends_on = [module.aws_eks_cluster] 
  name = module.aws_eks_cluster.cluster_name
}

# for auth-config map
provider "kubernetes" {
  # alias = "aws"
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
  # exec {
  #   api_version = "client.authentication.k8s.io/v1beta1"
  #   args        = ["eks", "get-token", "--cluster-name", module.aws_eks_cluster.cluster_name]
  #   command     = "aws"
  # }

  # lifecycle {
  #   ignore_changes = []
  # }

  #testing explicit dependency
  # depends_on = [data.aws_eks_cluster_auth.this,data.aws_eks_cluster.this]

}


provider "helm" {
  # alias = "eks"
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token

    # exec = {
    #   api_version = "client.authentication.k8s.io/v1beta1"
    #   args        = ["eks", "get-token", "--cluster-name",  module.aws_eks_cluster.cluster_name]
    #   command     = "aws"
    # }
  }
}


# Fetch Argo CD server details
# data "kubernetes_service" "argocd_server" {
#   provider = kubernetes.aws
#   depends_on = [ module.aws_eks_cluster ]
#   metadata {
#     name      = "argocd-server"
#     namespace = "argocd"
#   } 
# }


# provider "argocd" {
#   server_addr = "${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname != "" ? data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname : data.kubernetes_service.argocd_server.spec[0].cluster_ip}:443"
#   username    = var.argocd_username
#   password    = module.argocd.intial_argocd_secret
# }

