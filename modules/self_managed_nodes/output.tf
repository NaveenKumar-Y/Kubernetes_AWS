output "ec2_instance_profile_name" {
  description = "The name of the EC2 instance profile"
  value       = aws_iam_instance_profile.node_instance_profile.name
}

output "ssh_pulbic_key_name" {
  description = "The name of the SSH public key"
  value       = aws_key_pair.eks_kp.key_name
  
}