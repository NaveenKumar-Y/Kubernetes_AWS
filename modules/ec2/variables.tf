variable "ec2_public_subnet_id" {
  type        = string
  description = "The ID of the public subnet in which to launch the EC2 instance."
}


variable "ec2_instance_profile_name" {
  
}

# variable "github_pat_token" {
#   type        = string
#   description = "GitHub Personal Access Token for accessing private repositories."
#   sensitive = true
  
# }

# variable "GH_REPO_URL" {
  
# }

variable "ssh_pulbic_key_name" {
  
}

variable "github_repo" {
  type        = string
  description = "The name of the GitHub repository to register self hosted runner."
  default = "Docker"
  
}



variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the EC2 instance will be launched."
  
}