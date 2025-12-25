environment = "dev"

node_groups = {
  node_group_1 = {
    node_group_name = "dev-eks-node-group-1"
    instance_type   = ["t3.medium"]
    capacity_type   = "ON_DEMAND"
    desired_size    = 2
    max_size        = 3
    min_size        = 1
    disk_size       = 30
    ami_type        = "AL2_x86_64"
    taint           = []
    labels = {
      environment = "dev"
      role        = "worker"
    }
  }

  node_group_2 = {
    node_group_name = "dev-eks-node-group-2"
    instance_type   = ["t3.small"]
    capacity_type   = "SPOT"
    desired_size    = 1
    max_size        = 2
    min_size        = 1
    disk_size       = 20
    ami_type        = "AL2_x86_64"
    taint           = []
    labels = {
      environment = "dev"
      role        = "backend"
    }
  }
}