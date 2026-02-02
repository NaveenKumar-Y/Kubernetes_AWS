terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    #   configuration_aliases = [ kubernetes.eks ]
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }

    argocd = {
      source  = "argoproj-labs/argocd"
      version = "~> 7.12"
      # configuration_aliases = [ argocd ]
    }
  }

  required_version = "~>1.12.0"
}