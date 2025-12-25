resource "aws_eks_cluster" "my_eks_cluster" {
  name = var.cluster_name

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.cluster.arn
    # role_arn = data.aws_iam_role.pre_defined.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids = var.eks_subnet_ids
  }

  tags = {
    Environment = var.environment
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "aws_iam_role" "cluster" {
  name = "eksClusterRole"
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
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# data "aws_iam_role" "pre_defined" {
#   name = "AWSServiceRoleForAmazonEKS"
# }