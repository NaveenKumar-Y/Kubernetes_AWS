

locals {
  # Node IAM role(s)
  node_roles = [
    {
      rolearn  = aws_iam_role.node_role.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = [
        "system:bootstrappers",
        "system:nodes",
      ]
    }
  ]

}


resource "kubernetes_config_map_v1" "aws_auth" {

  # provider = kubernetes.aws

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }

  data = {
    mapRoles = yamlencode(local.node_roles)


    # mapUsers = yamlencode(local.admin_users)
    # You can also add mapAccounts if needed:
    # mapAccounts = yamlencode([])
  }

  # Optional safety if you never want destroy to delete it
  lifecycle {
    prevent_destroy = true
  }
}
