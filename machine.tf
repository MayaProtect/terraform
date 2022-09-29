resource "aws_instance" "mp_tool_gateway" {
  ami                    = "ami-096800910c1b781ba"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  credit_specification {
    cpu_credits = "standard"
  }
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.mp_tool_gateway_nic.id
  }
  tags = {
    Name = "mp_ssh_gateway"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "mayaprotect"
  public_key = file("./key")
}

resource "aws_network_interface" "mp_tool_gateway_nic" {
  subnet_id   = aws_subnet.mp_subnet_public.id
  private_ips = ["10.0.10.100"]
  security_groups = [
    aws_security_group.mp_ssh_gateway.id,
    aws_security_group.mp_ssh_from_gateway.id
  ]
}

resource "aws_eip" "mp_tool_gateway_eip" {
  vpc      = true
  instance = aws_instance.mp_tool_gateway.id
}
