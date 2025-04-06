# terraform-aws-vpc

Official Rockpenguin Technology Terraform module for basic AWS VPC terraforming.  We wanted a module that provided more customizations and provided options such as NAT instance EC2s.

## Usage

Simply create a Terraform project with .tf files using the following format:

```hcl
###############################################################################
# local variables - not necessary, but can help when using in multiple places
###############################################################################
locals {
  vpc_cidr = "10.123.0.0/16"
  aws_region = "us-east-2"
}

module "aws_vpc" {
  source = "github.com/rockpenguin/rockpenguin-aws-vpc"

  ###############################################################################
  # VPC Config
  ###############################################################################
  vpc_name             = "sandbox-vpc-use2"
  vpc_cidr             = local.vpc_cidr
  aws_region           = local.aws_region
  enable_dns_hostnames = true
  enable_dns_support   = true
  dhcp_options = {
    domain_name         = "ec2.internal"
    domain_name_servers = ["AmazonProvidedDNS"]
  }
  instance_tenancy = "default"
  natgw_enabled    = true

  ###############################################################################
  # Subnets (us-east-2)
  # us-east-2a (use2-az1)
  # us-east-2b (use2-az2)
  # us-east-2c (use2-az3)
  ###############################################################################
  subnets_private = {
    subnet-use2a-prv = {
      az_id                   = "use2-az1"
      cidr                    = "10.123.11.0/24"
      map_public_ip_on_launch = false
    }
    subnet-use2b-prv = {
      az_id                   = "use2-az2"
      cidr                    = "10.123.12.0/24"
      map_public_ip_on_launch = false
    }
  }

  subnets_public = {
    subnet-use2a-pub = {
      az_id                   = "use2-az1"
      cidr                    = "10.123.1.0/24"
      map_public_ip_on_launch = true
    }
    subnet-use2b-pub = {
      az_id                   = "use2-az2"
      cidr                    = "10.123.2.0/24"
      map_public_ip_on_launch = true
    }
  }


  ###############################################################################
  # Routing
  ###############################################################################
  # carrier_gateway_id, core_network_arn, egress_only_gateway_id,
  # gateway_id, instance_id, local_gateway_id, nat_gateway_id,
  # network_interface_id, transit_gateway_id, vpc_endpoint_id,
  # vpc_peering_connection_id

  routes_private = {
    default = {
      dest_cidr = "0.0.0.0/0"
      dest_type = "nat_gateway"
    }
  }
  routes_public = {
    default = {
      dest_cidr = "0.0.0.0/0"
      dest_type = "internet_gateway"
    }
  }

}
```

See the [variables.tf](variables.tf) file for required variables and their defaults.
