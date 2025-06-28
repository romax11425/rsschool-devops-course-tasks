# Bastion Host Security Group
resource "aws_security_group" "bastion" {
  name        = "bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bastion-SG"
  }
}

# Private Instances Security Group
resource "aws_security_group" "private_instances" {
  name        = "private-instances-sg"
  description = "Security group for private instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Private-Instances-SG"
  }
}

# K3s Cluster Security Group
resource "aws_security_group" "k3s_cluster" {
  name        = "k3s-cluster-sg"
  description = "Security group for k3s cluster nodes"
  vpc_id      = aws_vpc.main.id

  # SSH access from bastion
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # k3s API server
  ingress {
    from_port = 6443
    to_port   = 6443
    protocol  = "tcp"
    self      = true
  }

  # k3s API server access from bastion
  ingress {
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # Flannel VXLAN
  ingress {
    from_port = 8472
    to_port   = 8472
    protocol  = "udp"
    self      = true
  }

  # k3s metrics server
  ingress {
    from_port = 10250
    to_port   = 10250
    protocol  = "tcp"
    self      = true
  }

  # NodePort services range
  ingress {
    from_port = 30000
    to_port   = 32767
    protocol  = "tcp"
    self      = true
  }

  # Allow all internal cluster communication
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k3s-cluster-sg"
  }
}