## kodekloud playground doesn't allow creating node groups
# resource "aws_eks_node_group" "node_groups" {
#   for_each =  var.node_groups
#   cluster_name    = aws_eks_cluster.my_eks_cluster.name
#   node_group_name = each.value.node_group_name
#   node_role_arn   = aws_iam_role.node_role.arn
#   subnet_ids      = var.eks_subnet_ids

#   scaling_config {
#     desired_size = each.value.desired_size
#     max_size     = each.value.max_size
#     min_size     = each.value.min_size
#   }
#   ami_type = each.value.ami_type
#   disk_size = each.value.disk_size
#   instance_types = each.value.instance_type

#   update_config {
#     max_unavailable = 1
#   }

#   dynamic "taint" {
#     for_each = each.value.taint
#     content {
#       key    = each.value.key
#       value  = each.value.value
#       effect = each.value.effect
#     }
#   }

#   labels = each.value.labels

# #   dynamic "labels" {
# #     for_each = each.value.labels != null ? each.value.labels : {}
# #     content = {
# #     name  = each.key
# #     value = each.value
# #     }
# #   }

#   # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
#   # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#   depends_on = [
#     aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,  # Lets the kubelet register with the cluster API server and describe cluster resources.
#     aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,     # Gives the VPC CNI plugin permissions to manage ENIs, IP addresses, and security groups in your VPC.
#     aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,  # Allows pulling container images from Amazon ECR.
#   ]


# }




resource "aws_iam_role" "node_role" {
  name = "eksWorkerNodeRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  
}


resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
  
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role       = aws_iam_role.node_role.name
}
