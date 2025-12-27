
module "VPC" {
  source = "../../modules/network"
  #   vpc_ingress_rules    = var.eks_vpc_ingress_rules
  #   vpc_egress_rules     = var.eks_vpc_egress_rules
  private_subnet_count = 3
  public_subnet_count  = 3

}

module "aws_eks_cluster" {
  depends_on = [ module.VPC ]
  source         = "../../modules/eks_cluster1"
  cluster_name   = "demo-eks"
  eks_version    = "1.30"
  # eks_subnet_ids = module.VPC.private_subnet
  # environment    = var.environment
  # node_groups    = var.node_groups
  # vpc_id = module.VPC.vpc_id
  # additional_policy_arns = 
}

