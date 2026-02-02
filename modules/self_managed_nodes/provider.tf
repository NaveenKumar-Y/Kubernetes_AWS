terraform {
  required_providers {
    # Declare the source for the 'kubernetes' provider
    kubernetes = {
      source = "hashicorp/kubernetes"
      # Optionally add a version constraint here, e.g., version = "~> 2.0"
    }
  }
}

# provider "kubernetes" {
  
# }