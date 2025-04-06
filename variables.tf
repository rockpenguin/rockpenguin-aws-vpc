
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

variable "nat_gw_enabled" {
  description = "Enable NAT Gateway?"
  type = bool
  default = false
}

variable "nat_instance_ami" {
  description = "AMI ID for NAT instance (required)"
  type = string
}

variable "nat_instance_enabled" {
  description = "Enable NAT instance"
  type = bool
  default = false
}

variable "nat_instance_iam_profile" {
  description = "IAM instance profile for NAT instance"
  type = string
  default = "use_built_in"
}

variable "nat_instance_key_pair_name" {
  description = "SSH key pair for NAT instance"
  type = string
  default = ""
}

variable "nat_instance_type" {
  description = "Instance type for NAT instance (required)"
  type = string
}

variable "nat_instance_user_data" {
  description = "User data for NAT instance provisioning (overrides default)"
  type = string
  default = ""
}

variable "routes_custom_private" {
  description = "Additional custom private routes"
  default = {}
  type = map(object({
    dest_cidr = string
    dest_type = string
  }))
}

variable "routes_custom_public" {
  description = "Additional custom public routes"
  type = map(object({
    dest_cidr = string
    dest_type = string
  }))
}

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
