# ref: https://github.com/kodekloudhub/amazon-elastic-kubernetes-service-course/blob/main/eks/nodes.tf

# IAM Role for EKS Node Group Instances
resource "aws_iam_instance_profile" "node_instance_profile" {
  name = "NodeInstanceProfile"
  path = "/"
  role = aws_iam_role.node_role.id
}


# security groups

# Security group to apply to worker nodes
resource "aws_security_group" "node_security_group" {
  name        = "NodeSecurityGroupIngress"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id
  tags = {
    "Name" = "NodeSecurityGroupIngress"
  }
}

#
# Now follows several rules that are applied to the node securi group
# to allow control plane to access nodes
#

resource "aws_vpc_security_group_ingress_rule" "node_security_group_ingress" {
  description                  = "Allow node to communicate with each other"
  ip_protocol                  = "-1"
  security_group_id            = aws_security_group.node_security_group.id
  referenced_security_group_id = aws_security_group.node_security_group.id
}

# CloudFormation defaults to egress all. Terraform does not.
resource "aws_vpc_security_group_egress_rule" "node_egress_all" {
  description       = "Allow node egress to anywhere"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.node_security_group.id
}

resource "aws_vpc_security_group_ingress_rule" "node_security_group_from_control_plane_ingress" {
  description                  = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  security_group_id            = aws_security_group.node_security_group.id
  referenced_security_group_id = var.cluster_secuirity_group_id
  from_port                    = 1025
  to_port                      = 65535
  ip_protocol                  = "TCP"
}

resource "aws_vpc_security_group_ingress_rule" "control_plane_egress_to_node_security_group_on_443" {
  description                  = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane"
  security_group_id            = aws_security_group.node_security_group.id
  referenced_security_group_id = var.cluster_secuirity_group_id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "TCP"
}

#
# Now follows several rules that are applied to the EKS cluster security group
# to allow nodes to access control plane
#

resource "aws_vpc_security_group_ingress_rule" "cluster_control_plane_security_group_ingress" {
  description                  = "Allow pods to communicate with the cluster API Server"
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "TCP"
  referenced_security_group_id = aws_security_group.node_security_group.id
  security_group_id            = var.cluster_secuirity_group_id
}

resource "aws_vpc_security_group_egress_rule" "control_plane_egress_to_node_security_group" {
  description                  = "Allow the cluster control plane to communicate with worker Kubelet and pods"
  referenced_security_group_id = aws_security_group.node_security_group.id
  security_group_id            = var.cluster_secuirity_group_id
  from_port                    = 1025
  to_port                      = 65535
  ip_protocol                  = "TCP"
}

resource "aws_vpc_security_group_egress_rule" "control_plane_egress_to_node_security_group_on_443" {
  description                  = "Allow the cluster control plane to communicate with pods running extension API servers on port 443"
  referenced_security_group_id = aws_security_group.node_security_group.id
  security_group_id            = var.cluster_secuirity_group_id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "TCP"
}



#### Instance templates for unmanaged node groups

resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key to local .ssh directory so it can be used by SSH clients
resource "local_sensitive_file" "pem_file" {
  filename        = pathexpand("~/.ssh/eks-aws.pem")
  file_permission = "600"
  content         = tls_private_key.key_pair.private_key_pem
}

# Upload the public key of the key pair to AWS so it can be added to the instances
resource "aws_key_pair" "eks_kp" {
  key_name   = "eks_kp"
  public_key = trimspace(tls_private_key.key_pair.public_key_openssh)
}


# # Get AMI ID for latest recommended Amazon Linux 2 image
data "aws_ssm_parameter" "node_ami" {
  name = "/aws/service/eks/optimized-ami/1.30/amazon-linux-2/recommended/image_id"
}
# Support for Amazon Linux 2 on Amazon EKS will end on November 26, 2025

# Get AMI ID for latest recommended Amazon Linux 2023 EKS image
# data "aws_ssm_parameter" "node_ami" {
#   name = "/aws/service/eks/optimized-ami/1.30/amazon-linux-2023/x86_64/standard/recommended/image_id"
# }
# nodeadm failing to install on Amazon Linux 2023




# Launch Template defines how the autoscaling group will create worker nodes.
resource "aws_launch_template" "node_launch_template" {
  name = "NodeLaunchTemplate"
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      volume_size           = 30
      volume_type           = "gp2"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.node_instance_profile.name
  }

  key_name      = aws_key_pair.eks_kp.key_name
  instance_type = var.node_instance_type
  vpc_security_group_ids = [
    aws_security_group.node_security_group.id
  ]

  tags = {
    "Name" = "NodeLaunchTemplate"
  }

  image_id = data.aws_ssm_parameter.node_ami.value

  metadata_options {
    http_put_response_hop_limit = 2
    http_endpoint               = "enabled"
    http_tokens                 = "required"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "worker-node"
    }
  }

  user_data = base64encode(<<EOF
    #!/bin/bash
    set -o xtrace
    /etc/eks/bootstrap.sh ${var.cluster_name} \
        --kubelet-extra-args '--node-labels=role=worker,environment=${var.environment},instance_type=${var.node_instance_type}'
    EOF
  )

}


### requried for amazon linux 2, for 2023 its inbuilt
# user_data = base64encode(<<EOF
#     #!/bin/bash
#     set -o xtrace
#     /etc/eks/bootstrap.sh ${var.cluster_name} \
#         --kubelet-extra-args '--node-labels=role=worker,environment=${var.environment},instance_type=${var.node_instance_type}'
#     EOF
#   )


#Auto Scaling Group for EKS Worker Nodes
resource "aws_autoscaling_group" "node_group" {
  name = "eks-cluster-asg"

  vpc_zone_identifier = var.eks_subnet_ids
#   [
#     data.aws_subnets.public.ids[0],
#     data.aws_subnets.public.ids[1],
#     data.aws_subnets.public.ids[2],
#   ]

  min_size         = var.node_group_min_size
  max_size         = var.node_group_max_size
  desired_capacity = var.node_group_desired_capacity

  health_check_type = "EC2"

  launch_template {
    id      = aws_launch_template.node_launch_template.id
    version = aws_launch_template.node_launch_template.latest_version
  }

  # Rough equivalent of AutoScalingRollingUpdate
  instance_refresh {
    strategy = "Rolling"

    preferences {
      # MaxBatchSize: 1  => only 1 instance updated at a time
      min_healthy_percentage = 100
      instance_warmup        = 300   # similar to PauseTime: PT5M
    }

    # Trigger rolling update when launch template changes
    triggers = ["launch_template"]
  }

  # (Optional) tags, target group attachments, etc.
  lifecycle {
    create_before_destroy = true
  }
}

# # EKS Access Control for Nodes(instead of manually editing aws-auth ConfigMap)
# resource "aws_eks_access_entry" "nodes" {
#   cluster_name  = var.cluster_name
#   principal_arn = aws_iam_role.node_role.arn
#   type          = "EC2_LINUX"   # for self-managed Linux nodes
#   # user_name is optional for nodes; EKS will use a default node identity
# }

# resource "aws_eks_access_policy_association" "nodes" {
#   cluster_name = var.cluster_name
#   principal_arn = aws_iam_role.node_role.arn

#   # This is the standard EKS-managed policy that gives nodes
#   # the kubelet permissions (system:nodes etc.)
#   policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSNodePolicy"

#   access_scope {
#     type = "cluster"   # nodes need cluster-wide scope
#   }
# }

####################### instead of ASG we can use CloudFormation 

# Wait for LT to settle, or CloudFormation may fail
# resource "time_sleep" "wait_30_seconds" {
#   depends_on = [
#     aws_launch_template.node_launch_template
#   ]

#   create_duration = "30s"
# }

# Defer to CloudFormation here to create AutoScalingGroup
# as the terraform ASG resource does not support UpdatePolicy
# resource "aws_cloudformation_stack" "autoscaling_group" {
#   depends_on = [
#     time_sleep.wait_30_seconds
#   ]
#   name          = "${var.cluster_name}-stack"
#   template_body = <<EOF
# Description: "Node autoscaler"
# Resources:
#   NodeGroup:
#     Type: AWS::AutoScaling::AutoScalingGroup
#     Properties:
#       VPCZoneIdentifier: [${join(",", var.eks_subnet_ids)}]
#       MinSize: "${var.node_group_min_size}"
#       MaxSize: "${var.node_group_max_size}"
#       DesiredCapacity: "${var.node_group_desired_capacity}"
#       HealthCheckType: EC2
#       LaunchTemplate:
#         LaunchTemplateId: "${aws_launch_template.node_launch_template.id}"
#         Version: "${aws_launch_template.node_launch_template.latest_version}"
#     UpdatePolicy:
#     # Ignore differences in group size properties caused by scheduled actions
#       AutoScalingScheduledAction:
#         IgnoreUnmodifiedGroupSizeProperties: true
#       AutoScalingRollingUpdate:
#         MaxBatchSize: 1
#         MinInstancesInService: "${var.node_group_desired_capacity}"
#         PauseTime: PT5M
# Outputs:
#   NodeAutoScalingGroup:
#     Description: The autoscaling group
#     Value: !Ref NodeGroup
#   EOF
# }

