output "vpc_sg_id" {
  value       = aws_security_group.name.id
  description = "value of the security group ID created for the VPC"
}

output "private_subnet" {
  # value = aws_subnet.private[0].id #one(aws_subnet.private[*].id)
  value = aws_subnet.private[*].id
}

output "public_subnet" {
  # value = aws_subnet.public[0].id #one(aws_subnet.public[*].id)
  value = aws_subnet.public[*].id
}

output "vpc_id" {
  value       = aws_vpc.custom1[0].id
  description = "The ID of the VPC created"

}