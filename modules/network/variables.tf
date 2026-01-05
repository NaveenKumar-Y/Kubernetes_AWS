variable "create_vpc" {
  default     = true
  type        = bool
  description = "create vpc"
}

variable "vpc_cidr_range" {
  default = "10.0.0.0/16"
  type    = string
}

variable "instance_tenancy" {
  default     = "default"
  type        = string
  description = "tenancy"
}

variable "enable_dns_hostnames" {
  default = true
  type    = bool
}

variable "tags" {
  default     = {}
  type        = map(any)
  description = "vpc tags"
}

variable "public_subnet_count" {
  default = 2
  type    = number
}

variable "private_subnet_count" {
  default = 2
  type    = number
}


variable "az_zones" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
  type    = list(string)
}

# variable "vpc_ingress_rules" {
#   type = list(object({
#     from_port   = number
#     to_port     = number
#     protocol    = string
#     cidr_blocks = list(string)
#     description = optional(string, "Allow all inbound traffic")
#   }))
# }


# variable "vpc_egress_rules" {
#   type = list(object({
#     from_port   = number
#     to_port     = number
#     protocol    = string
#     cidr_blocks = list(string)
#     description = optional(string, "Allow all outbound traffic")
#   }))
  # default = [{
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = -1
  #   cidr_blocks = ["0.0.0.0/0"]
  # }]
# }