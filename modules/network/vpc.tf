
resource "aws_vpc" "custom1" {
  count            = var.create_vpc ? 1 : 0
  cidr_block       = var.vpc_cidr_range
  instance_tenancy = var.instance_tenancy

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = true


  tags = merge({ "purpose" = "eks-demo" }, var.tags)
}


resource "aws_security_group" "name" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.custom1[0].id

  # dynamic "ingress" {
  #   for_each = var.vpc_ingress_rules
  #   content {
  #     from_port   = ingress.value.from_port
  #     to_port     = ingress.value.to_port
  #     protocol    = ingress.value.protocol
  #     cidr_blocks = ingress.value.cidr_blocks
  #   }
  # }

  # dynamic "egress" {
  #   for_each = var.vpc_egress_rules
  #   content {
  #     from_port   = egress.value.from_port
  #     to_port     = egress.value.to_port
  #     protocol    = egress.value.protocol
  #     cidr_blocks = egress.value.cidr_blocks
    # }

  # }


}