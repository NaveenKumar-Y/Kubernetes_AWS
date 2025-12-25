# FLOW:

# PUBLIC SUBNET:
#   EC2 Instance → Public Route Table → IGW → Internet  (direct access)

# PRIVATE SUBNET (via NAT):
#   EC2 Instance → Private Route Table → NAT Gateway → IGW → Internet  (secure, one-way out)


######## INTERNET GATEWAY ############

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.custom1[0].id
  tags = {
    Name = "internet-gateway-for-public-subnets"
  }
}

######## PUBLIC ROUTE TABLE ############

#### create a route table for public subnets ####
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.custom1[0].id
  tags = {
    Name = "public-route-table"
  }
}

#### create route in the above route table to direct internet-bound traffic to the internet gateway ####
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}
########################################################



############ associating public subnets with public route table ############
resource "aws_route_table_association" "public_route_table_association" {
  count          = var.create_vpc ? var.public_subnet_count : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}
###########################################################################


############## associating NAT public subnet with public route table ##############
resource "aws_route_table_association" "public_NAT_route_table_association" {
  subnet_id      = aws_subnet.public_for_NAT.id
  route_table_id = aws_route_table.public_route_table.id
}
###############################################################################



### PRIVATE ROUTE TABLE ####

### create a custom route table for private subnets ###
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.custom1[0].id
  tags = {
    Name = "private-route-table"
  }
}

### create route in the above route table to direct internet-bound traffic to the NAT gateway ###
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.NAT.id
}


############ associating private subnets with private route table ############
resource "aws_route_table_association" "private_route_table_association_to_NAT" {
  count          = var.create_vpc ? var.private_subnet_count : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}
###########################################################################
