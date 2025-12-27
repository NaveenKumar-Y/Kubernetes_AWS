# Configure the AWS Provider
provider "aws" {
  # Configuration options
  region = "us-east-1"
  profile = "default"
}


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
  # alias = "eks"
  host                   = data.aws_eks_cluster.this.endpoint
  # host = "https://FF651F3DEEF650E857ACB94480112942.gr7.us-east-1.eks.amazonaws.com"
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}