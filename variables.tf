
variable "aws_region" {
  description = "AWS Region"
  type = string
  default = "us-east-1"
}

variable "dhcp_options" {
  description = "VPC DHCP Options"
  type = object({
    domain_name = string
    domain_name_servers = list(string)
  })
  default = {
    domain_name = "ec2.internal",
    domain_name_servers = ["AmazonProvidedDNS"]
  }
}

variable "enable_dns_hostnames" {
  description = "Should DNS hostnames be enabled"
  type = bool
  default = true
}

variable "enable_dns_support" {
  description = "Should DNS support be enabled"
  type = bool
  default = true
}

variable "env" {
  type = string
  description = "Environment (dev|tst|prd)"
  default = "dev"
}

variable "instance_tenancy" {
  description = "VPC instance tenancy"
  type = string
  default = "default"
}

variable "natgw_enabled" {
  description = "Enable NAT Gateway?"
  type = bool
  default = false
}

variable "routes_private" {
  description = "Private routes definitions"
  default = {}
  type = map(object({
    dest_cidr = string
    dest_type = string
  }))
}

variable "routes_public" {
  description = "Public routes definitions"
  type = map(object({
    dest_cidr = string
    dest_type = string
  }))
}

# variable "security_groups" {
#   description = "Security groups"
#   type = map(object(
#     {
#       description = string
#       ingress_rules = list(string)
#       egress_rules = list(string)
#     }
#   ))
#   default = {}
# }

# variable "security_group_rules" {
#   description = "Security group rules"
#   type = map(object(
#     {
#       cidr_ipv4 = string
#       protocol = string
#       beg_port = string
#       end_port = string
#     }
#   ))
# }

variable "subnets_private" {
  description = "Private subnet definitions"
  type = map(
    object({
      az_id = string
      cidr = string
      map_public_ip_on_launch = bool
    })
  )
}

variable "subnets_public" {
  description = "Public subnet definitions"
  type = map(object({
      az_id = string
      cidr = string
      map_public_ip_on_launch = bool
  }))
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type = string
}

variable "vpc_name" {
  description = "VPC name"
  type = string
}
