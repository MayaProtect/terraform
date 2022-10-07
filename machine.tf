variable "ssh_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "gateway" {
  type    = object({
    disk_size = number
    instance_type = string
    name          = string
    cpu_credits   = string
  })
  default = {
    disk_size = 8
    instance_type = "t2.nano"
    name          = "mp-tool-gateway"
    cpu_credits   = "standard"
  }
}

variable "instance_master_node" {
  type = object({
    name               = string
    instance_type      = string
    security_group_ids = list(string)
    disk_size          = number
  })
  default = {
    name               = "master"
    instance_type      = "t2.micro"
    security_group_ids = []
    disk_size          = 50
  }
}

variable "instances_node" {
  type = map(object({
    name               = string
    instance_type      = string
    security_group_ids = list(string)
    disk_size          = number
  }))
  default = {
    "node1" = {
      name               = "node1"
      instance_type      = "t2.micro"
      security_group_ids = []
      disk_size          = 50
    }
    "node2" = {
      name               = "node2"
      instance_type      = "t2.micro"
      security_group_ids = []
      disk_size          = 50
    }
  }
}

resource "aws_instance" "mp_tool_gateway" {
  ami           = "ami-096800910c1b781ba"
  instance_type = var.gateway.instance_type
  key_name      = aws_key_pair.deployer.key_name
  credit_specification {
    cpu_credits = var.gateway.cpu_credits
  }
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.mp_tool_gateway_nic.id
  }
  root_block_device {
    volume_size = var.gateway.disk_size
  }
  tags = {
    Name = var.gateway.name
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
  root_block_device {
    volume_size = var.instance_master_node.disk_size
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
  root_block_device {
    volume_size = each.value.disk_size
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
    aws_security_group.mp_sg_kubernetes.id,
    aws_security_group.mp_web.id
  ]
  tags = {
    "Name" = "nic_${each.value.name}"
  }
}
