locals {
  cidr_private = cidrsubnet(aws_vpc.custom1[0].cidr_block, 4, 0)
  cidr_public  = cidrsubnet(aws_vpc.custom1[0].cidr_block, 4, 1)

  NAT_public_subnet_cidr = cidrsubnet(aws_vpc.custom1[0].cidr_block, 4, 2)
}

## translatets to :
# locals {
#   cidr_private = cidrsubnet("10.0.0.0/16", 4, 0)
#   cidr_public  = cidrsubnet("10.0.0.0/16", 4, 1)
# }


locals {
  # az_zones = var.az_zones
  public_subnet_cidrs  = [for i in range(var.public_subnet_count) : cidrsubnet(local.cidr_public, 4, i)]
  private_subnet_cidrs = [for i in range(var.private_subnet_count) : cidrsubnet(local.cidr_private, 4, i)]
}


########## subnets creation ##############
resource "aws_subnet" "private" {
  count             = var.create_vpc ? var.private_subnet_count : 0
  vpc_id            = aws_vpc.custom1[0].id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = element(var.az_zones, count.index)

  tags = {
    Name = "private-subnet-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1"    # MUST NEED: to eks and LB controller know that these subnets used for NLB
    "kubernetes.io/cluster/${var.environment}-eks-demo" = "owned"  # optional but best practice
  }

}

resource "aws_subnet" "public" {
  count             = var.create_vpc ? var.public_subnet_count : 0
  vpc_id            = aws_vpc.custom1[0].id
  cidr_block        = local.public_subnet_cidrs[count.index]
  availability_zone = element(var.az_zones, count.index)
  tags = {
    Name = "public-subnet-${count.index + 1}"
    "kubernetes.io/role/elb" = "1"    # MUST NEED: to eks and LB controller know that these subnets used for ELB
    "kubernetes.io/cluster/${var.environment}-eks-demo" = "owned"  # optional but best practice
  }
}


resource "aws_subnet" "public_for_NAT" {
  # count             = 1
  vpc_id            = aws_vpc.custom1[0].id
  cidr_block        = local.NAT_public_subnet_cidr
  availability_zone = element(var.az_zones, 2)
  tags = {
    Name = "public-subnet-NAT"
  }
}
##########################################

