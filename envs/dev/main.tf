
module "VPC" {
  source = "../../modules/network"
  #   vpc_ingress_rules    = var.eks_vpc_ingress_rules
  #   vpc_egress_rules     = var.eks_vpc_egress_rules
  private_subnet_count = 3
  public_subnet_count  = 3

}

module "aws_eks_cluster" {
  depends_on = [ module.VPC ]
  source         = "../../modules/eks_cluster"
  cluster_name   = "demo-eks"
  eks_version    = "1.30"
  eks_subnet_ids = module.VPC.private_subnet
  environment    = var.environment
  node_groups    = var.node_groups
  
  # vpc_id = module.VPC.vpc_id
}


module "self_managed_nodes" {
  providers = {
    kubernetes = kubernetes.eks
  }
  source         = "../../modules/self_managed_nodes"
  vpc_id         = module.VPC.vpc_id
  eks_subnet_ids = module.VPC.private_subnet
  environment    = var.environment
  cluster_name = module.aws_eks_cluster.cluster_name
  cluster_secuirity_group_id = module.aws_eks_cluster.cluster_security_group_id
}

module "ecr" {
  source = "../../modules/ecr"
  environment = var.environment
} 

module "ec2" {
  source = "../../modules/ec2"
  # environment = var.environment
  ec2_public_subnet_id = module.VPC.public_subnet[0]
  ec2_instance_profile_name = module.self_managed_nodes.ec2_instance_profile_name
  # github_pat_token = var.github_pat_token
  # GH_REPO_URL = var.GH_REPO_URL
  ssh_pulbic_key_name = module.self_managed_nodes.ssh_pulbic_key_name
  vpc_id = module.VPC.vpc_id


  
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [ module.self_managed_nodes ]
  create_duration = "60s"
  
}

module "argocd" {
  depends_on = [ module.aws_eks_cluster , resource.time_sleep.wait_60_seconds ]
  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }
  source = "../../modules/argocd"
  # argocd_helm_chart_version = "6.4.5"
  
}