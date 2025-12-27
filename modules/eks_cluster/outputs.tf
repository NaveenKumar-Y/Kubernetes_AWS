output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.my_eks_cluster.name

}

output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = aws_eks_cluster.my_eks_cluster.id
  
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = aws_eks_cluster.my_eks_cluster.arn
  
}

# connection details
output "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = aws_eks_cluster.my_eks_cluster.endpoint

}

output "cluster_certificate_authority_data" {
  description = "The certificate authority data for the EKS cluster"
  value       = aws_eks_cluster.my_eks_cluster.certificate_authority[0].data
  
}

output "cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster"
  value       = aws_eks_cluster.my_eks_cluster.identity[0].oidc[0].issuer

}

output "cluster_security_group_id" {
  description = "The security group ID of the EKS cluster"
  value       = aws_eks_cluster.my_eks_cluster.vpc_config[0].cluster_security_group_id
  
}


