################################################################################
# Provider Config
################################################################################
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      environment = var.env
    }
  }
}

################################################################################
# Local vars
################################################################################
locals {

  my_vpc_name = format("%s-%s", var.vpc_name, var.aws_region)

  private_route_gw_enabled = anytrue(
    [var.nat_gw_enabled, var.nat_instance_enabled]
  )

}

################################################################################
# VPC
################################################################################
resource "aws_vpc" "self" {

  cidr_block            = var.vpc_cidr
  enable_dns_hostnames  = var.enable_dns_hostnames
  enable_dns_support    = var.enable_dns_support
  instance_tenancy      = var.instance_tenancy

  tags = {
    Name = local.my_vpc_name
  }
}

resource "aws_vpc_dhcp_options" "self" {
  domain_name          = var.dhcp_options.domain_name
  domain_name_servers  = var.dhcp_options.domain_name_servers

  tags = {
    Name = format("dhcp-opts-%s", local.my_vpc_name)
  }
}

resource "aws_vpc_dhcp_options_association" "self" {
  vpc_id          = aws_vpc.self.id
  dhcp_options_id = aws_vpc_dhcp_options.self.id
}

resource "aws_internet_gateway" "self" {
  vpc_id = aws_vpc.self.id
  tags = {
    Name = format("igw-%s", local.my_vpc_name)
  }
}

###############################################################################
# Subnets
###############################################################################
resource "aws_subnet" "private" {
  for_each = var.subnets_private

  vpc_id = aws_vpc.self.id
  cidr_block = each.value["cidr"]
  availability_zone_id = each.value["az_id"]
  map_public_ip_on_launch = each.value["map_public_ip_on_launch"]

  tags = {
    # Name = format("prv-%s-%s", each.key, local.my_vpc_name)
    Name = each.key
  }
}

resource "aws_subnet" "public" {
  for_each = var.subnets_public

  vpc_id = aws_vpc.self.id
  cidr_block = each.value["cidr"]
  availability_zone_id = each.value["az_id"]
  map_public_ip_on_launch = each.value["map_public_ip_on_launch"]

  tags = {
    # Name = format("pub-%s-%s", each.key, local.my_vpc_name)
    Name = each.key
  }
}

###############################################################################
# NAT Gateways
###############################################################################
resource "aws_eip" "nat_gw" {
  count = var.nat_gw_enabled ? 1 : 0

  public_ipv4_pool = "amazon"
  domain = "vpc"

  tags = {
    Name = format("eip-nat-gw-%s", local.my_vpc_name)
  }
}

resource "aws_nat_gateway" "self" {
  count = var.nat_gw_enabled ? 1 : 0

  allocation_id     = aws_eip.nat_gw[0].id
  connectivity_type = "public"

  # Let's pick the first public subnet
  subnet_id = element([for subnet in aws_subnet.public: subnet.id], 0)
  tags = {
    Name = format("nat-gw-%s", local.my_vpc_name)
  }

  depends_on = [aws_internet_gateway.self]
}

###############################################################################
# Private Routing
###############################################################################

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.self.id

  tags = {
    Name = format("prv-%s", local.my_vpc_name)
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "private_default" {
  count = local.private_route_gw_enabled ? 1 : 0

  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = var.nat_gw_enabled ? aws_nat_gateway.self[0].id : null
  network_interface_id = var.nat_instance_enabled ? aws_network_interface.nat_instance_nic[0].id : null
}

# resource "aws_route" "private_custom" {
#   for_each = var.routes_custom_private

#   route_table_id = aws_route_table.private.id
#   destination_cidr_block = each.value["dest_cidr"]

#   # instance_id = each.value["dest_type"] == "instance_id" ?
#   vpc_endpoint_id =
#   # carrier_gateway_id, core_network_arn, egress_only_gateway_id,
#   # gateway_id, instance_id, local_gateway_id, nat_gateway_id,
#   # network_interface_id, transit_gateway_id, vpc_endpoint_id,
#   # vpc_peering_connection_id
# }

###############################################################################
# Public Routing
###############################################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.self.id

  tags = {
    Name = format("pub-%s", local.my_vpc_name)
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_default" {
  # for_each = var.routes_custom_public

  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.self.id
}

# resource "aws_route" "public_custom" {
#   for_each = var.routes_custom_public

#   route_table_id = aws_route_table.public.id
#   destination_cidr_block = each.value["dest_cidr"]

#   gateway_id = each.value["dest_type"] == "internet_gateway" ? aws_internet_gateway.self.id : null
# }


################################################################################
# Default Route
################################################################################

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.self.default_route_table_id

  route = []

  timeouts {
    create = "5m"
    update = "5m"
  }

  tags = {
    Name = "default_route_table"
  }
}
