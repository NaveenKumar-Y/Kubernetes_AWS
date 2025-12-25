
terraform {
  cloud {

    organization = "Naveen_org"

    workspaces {
      name = "AWS_EKS_dev"
    }
  }
}