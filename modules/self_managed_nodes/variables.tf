
variable "vpc_id" {
  description = "The VPC ID where the EKS cluster will be deployed"
  type        = string
  
}


variable "eks_subnet_ids" {
  description = "A list of subnet IDs for the EKS cluster"
  type        = list(string)

}

variable "environment" {
  description = "The environment for the EKS cluster (e.g., dev, prod)"
  type        = string

}



variable "node_group_min_size" {
  description = "Minimum size of the EKS node group"
  type        = number
  default     = 1
  
}

variable "node_group_max_size" {
  description = "Maximum size of the EKS node group"
  type        = number
  default     = 3
  
}

variable "node_group_desired_capacity" {
  description = "Desired size of the EKS node group"
  type        = number
  default     = 2
  
}

variable "node_instance_type" {
  description = "EC2 instance type for the EKS node group"
  type        = string
  default     = "t3.medium"
  
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string  
  
}

variable "cluster_secuirity_group_id" {
    description = "The security group ID for the EKS cluster"
    type        = string
  
}

# variable "cluster_endpoint" {
#   description = "The endpoint of the EKS cluster"
#   type        = string  
  
# }

# variable "cluster_certificate_authority_data" {
#   description = "The certificate authority data for the EKS cluster"
#   type        = string  
  
# }

# variable "cluster_token" {
#   description = "The authentication token for the EKS cluster"
#   type        = string  
  
# }

