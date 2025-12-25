resource "aws_eip" "NAT_eip" {
  domain = "vpc" # Use "vpc" for VPC-based EIPs
  tags = {
    Name = "NAT EIP"
  }
}


resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.NAT_eip.id
  subnet_id     = aws_subnet.public_for_NAT.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.internet_gateway]
}