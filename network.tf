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
}

resource "aws_subnet" "mp_subnet_private" {
  vpc_id     = aws_vpc.mp_vpc.id
  cidr_block = "10.0.128.0/20"
}

resource "aws_internet_gateway" "mp_igw" {
  vpc_id = aws_vpc.mp_vpc.id
}

# Add Elastic IP to the Internet Gateway

