# terraform-aws-vpc

Official Rockpenguin Technology Terraform module for basic AWS VPC terraforming.

## Usage

Simply create a Terraform project with .tf files using the following format:

```hcl
module "vpc" {
  source = "../terraform-aws-vpc"

  ###############################################################################
  # VPC Config
  ###############################################################################
  vpc_name             = "datacenter-prd"
  vpc_cidr             = "10.1.0.0/16"
  vpc_region           = "us-east-1"
  enable_dns_hostnames = true
  enable_dns_support   = true
  dhcp_options = {
    domain_name         = "ec2.internal"
    domain_name_servers = ["AmazonProvidedDNS"]
  }
  instance_tenancy = "default"
  natgw_enabled    = true

  ###############################################################################
  # Subnets
  ###############################################################################
  subnets_private = {
    use1-az4 = {
      az_id                   = "use1-az4"
      cidr                    = "10.1.11.0/24"
      map_public_ip_on_launch = false
    }
    use1-az5 = {
      az_id                   = "use1-az5"
      cidr                    = "10.1.12.0/24"
      map_public_ip_on_launch = false
    }
  }

  subnets_public = {
    use1-az4 = {
      az_id                   = "use1-az4"
      cidr                    = "10.1.1.0/24"
      map_public_ip_on_launch = true
    }
    use1-az5 = {
      az_id                   = "use1-az5"
      cidr                    = "10.1.2.0/24"
      map_public_ip_on_launch = true
    }
  }


  ###############################################################################
  # Routing
  ###############################################################################
  routes_private = {
    default = {
      dest_cidr = "0.0.0.0/0"
      dest_type = "nat_gateway"
    }
    polo = {
      dest_cidr = "192.168.1.0/24"
      dest_type = "network_interface"
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
