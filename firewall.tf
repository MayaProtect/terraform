resource "aws_security_group" "mp_ssh_gateway" {
  name        = "mp_ssh_gateway"
  description = "Allow SSH from the Internet"
  vpc_id      = aws_vpc.mp_vpc.id
  ingress {
    description = "Allow SSH from the Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "allow_ssh"
  }
}

resource "aws_security_group" "mp_ssh_from_gateway" {
  name        = "mp_ssh_from_gateway"
  description = "Allow SSH from the Internet"
  vpc_id      = aws_vpc.mp_vpc.id
  ingress {
    description     = "Allow SSH from the Internet"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.mp_ssh_gateway.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "allow_ssh_from_gateway"
  }
}

resource "aws_security_group" "mp_sg_kubernetes" {
  name        = "mp_sg_kubernetes"
  description = "Allow Kubernetes traffic"
  vpc_id      = aws_vpc.mp_vpc.id
  ingress = [
    {
      description      = "kubernetes api server"
      from_port        = 6443
      to_port          = 6443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "kubelet api server"
      from_port        = 10250
      to_port          = 10250
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.mp_vpc.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "kube-scheduler"
      from_port        = 10259
      to_port          = 10259
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.mp_vpc.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "kube-controller-manager"
      from_port        = 10257
      to_port          = 10257
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.mp_vpc.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "etcd server client API"
      from_port        = 2379
      to_port          = 2379
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.mp_vpc.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "etcd server peer API"
      from_port        = 2380
      to_port          = 2380
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.mp_vpc.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "NodePort Services"
      from_port        = 30000
      to_port          = 32767
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.mp_vpc.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "ICMP"
      from_port        = -1
      to_port          = -1
      protocol         = "icmp"
      cidr_blocks      = [aws_vpc.mp_vpc.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
  ]
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "allow_kubernetes"
  }
}

resource "aws_security_group" "mp_web" {
  name        = "mp_web"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.mp_vpc.id
  ingress = [
    {
      description      = "Allow web traffic"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "Allow web traffic"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.mp_vpc.cidr_block]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
  egress {
    description      = "Allow web traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }
}
