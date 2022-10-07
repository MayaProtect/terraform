resource "aws_vpc" "mp_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_vpc_dhcp_options" "mp_dhcp_options" {
  domain_name         = "srv.mayaprotect.ovh"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "mp_dhcp_options_association" {
  vpc_id          = aws_vpc.mp_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.mp_dhcp_options.id
}

resource "aws_subnet" "mp_subnet_public" {
  vpc_id     = aws_vpc.mp_vpc.id
  cidr_block = "10.0.0.0/20"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "mp_subnet_private" {
  vpc_id     = aws_vpc.mp_vpc.id
  cidr_block = "10.0.128.0/20"
}

resource "aws_route_table" "mp_route_table" {
  vpc_id = aws_vpc.mp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mp_igw.id
  }

  tags = {
    Name = "mayaprotect_route_table"
  }
}

resource "aws_main_route_table_association" "mp_default_route_table_association" {
  route_table_id = aws_route_table.mp_route_table.id
  vpc_id         = aws_vpc.mp_vpc.id
}

resource "aws_internet_gateway" "mp_igw" {
  vpc_id = aws_vpc.mp_vpc.id
}

# Add Elastic IP to the Internet Gateway

