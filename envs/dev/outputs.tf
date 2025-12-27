output "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = module.aws_eks_cluster.cluster_endpoint
  
}