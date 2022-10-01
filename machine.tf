variable "ssh_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "instance_master_node" {
  type = object({
    name               = string
    instance_type      = string
    security_group_ids = list(string)
  })
  default = {
    name               = "master"
    instance_type      = "t2.micro"
    security_group_ids = []
  }
}

variable "instances_node" {
  type = map(object({
    name               = string
    instance_type      = string
    security_group_ids = list(string)
  }))
  default = {
    "node1" = {
      name               = "node1"
      instance_type      = "t2.micro"
      security_group_ids = []
    }
    "node2" = {
      name               = "node2"
      instance_type      = "t2.micro"
      security_group_ids = []
    }
  }
}

resource "aws_instance" "mp_tool_gateway" {
  ami           = "ami-096800910c1b781ba"
  instance_type = "t2.nano"
  key_name      = aws_key_pair.deployer.key_name
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
  public_key = file(var.ssh_key_path)
}

resource "aws_network_interface" "mp_tool_gateway_nic" {
  subnet_id   = aws_subnet.mp_subnet_public.id
  private_ips = ["10.0.10.100"]
  security_groups = [
    aws_security_group.mp_ssh_gateway.id
  ]
}

resource "aws_eip" "mp_tool_gateway_eip" {
  vpc      = true
  instance = aws_instance.mp_tool_gateway.id
}

resource "aws_instance" "mp_master" {
  ami           = "ami-096800910c1b781ba"
  instance_type = var.instance_master_node.instance_type
  key_name      = aws_key_pair.deployer.key_name
  credit_specification {
    cpu_credits = "standard"
  }
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.mp_master_nic.id
  }

  tags = {
    Name = "mp_master"
  }
}

resource "aws_network_interface" "mp_master_nic" {
  subnet_id   = aws_subnet.mp_subnet_public.id
  private_ips = ["10.0.10.150"]
  security_groups = [
    aws_security_group.mp_ssh_from_gateway.id,
    aws_security_group.mp_sg_kubernetes.id,
    aws_security_group.mp_web.id
  ]
}

resource "aws_eip" "mp_master_eip" {
  vpc      = true
  instance = aws_instance.mp_master.id
}

resource "aws_instance" "mp_nodes" {
  for_each      = var.instances_node
  ami           = "ami-096800910c1b781ba"
  instance_type = each.value.instance_type
  key_name      = aws_key_pair.deployer.key_name
  credit_specification {
    cpu_credits = "standard"
  }
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.mp_node_nic[each.key].id
  }
  tags = {
    Name = each.value.name
  }
}

resource "aws_network_interface" "mp_node_nic" {
  for_each  = var.instances_node
  subnet_id = aws_subnet.mp_subnet_public.id
  security_groups = [
    aws_security_group.mp_ssh_from_gateway.id,
    aws_security_group.mp_sg_kubernetes.id
  ]
  tags = {
    "Name" = "nic_${each.value.name}"
  }
}
