################################################################################
# Provider Config
################################################################################
provider "aws" {
  region = var.vpc_region
  default_tags {
    tags = {
      environment = var.env
    }
  }
}

locals {
  my_vpc_name = format("%s-%s", var.vpc_name, var.vpc_region)
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
    Name = format("prv-%s-%s", each.key, local.my_vpc_name)
  }
}

resource "aws_subnet" "public" {
  for_each = var.subnets_public

  vpc_id = aws_vpc.self.id
  cidr_block = each.value["cidr"]
  availability_zone_id = each.value["az_id"]
  map_public_ip_on_launch = each.value["map_public_ip_on_launch"]

  tags = {
    Name = format("pub-%s-%s", each.key, local.my_vpc_name)
  }
}

###############################################################################
# NAT Gateways
###############################################################################
resource "aws_eip" "natgw" {
  count = var.natgw_enabled ? 1 : 0

  public_ipv4_pool = "amazon"
  vpc = true

  tags = {
    Name = format("eip-natgw-%s", local.my_vpc_name)
  }
}

resource "aws_nat_gateway" "self" {
  count = var.natgw_enabled ? 1 : 0

  allocation_id     = aws_eip.natgw[0].id
  connectivity_type = "public"

  # Let's pick the first public subnet
  subnet_id = element([for subnet in aws_subnet.public: subnet.id], 0)
  tags = {
    Name = format("natgw-%s", local.my_vpc_name)
  }

  depends_on = [aws_internet_gateway.self]
}

###############################################################################
# Routing
###############################################################################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.self.id

  tags = {
    Name = format("prv-%s", local.my_vpc_name)
  }
}

resource "aws_route" "private" {
  for_each = var.routes_private

  route_table_id = aws_route_table.private.id
  destination_cidr_block = each.value["dest_cidr"]

  nat_gateway_id = each.value["dest_type"] == "nat_gateway" ? aws_nat_gateway.self[0].id : null
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.self.id

  tags = {
    Name = format("pub-%s", local.my_vpc_name)
  }
}

resource "aws_route" "public" {
  for_each = var.routes_public

  route_table_id = aws_route_table.public.id
  destination_cidr_block = each.value["dest_cidr"]

  gateway_id = each.value["dest_type"] == "internet_gateway" ? aws_internet_gateway.self.id : null
}

###############################################################################
# Routing/Subnet Associations
###############################################################################
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}
