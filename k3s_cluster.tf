# Generate a random token for k3s cluster
resource "random_password" "k3s_token" {
  length  = 64
  special = false
}

# K3s Master Node
resource "aws_instance" "k3s_master" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.k3s_cluster.id]
  key_name               = aws_key_pair.task2_key.key_name

  user_data = base64encode(templatefile("${path.module}/scripts/k3s-master.sh", {
    k3s_token = random_password.k3s_token.result
  }))

  tags = {
    Name = "k3s-master"
    Role = "master"
  }
}

# K3s Worker Node
resource "aws_instance" "k3s_worker" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private[1].id
  vpc_security_group_ids = [aws_security_group.k3s_cluster.id]
  key_name               = aws_key_pair.task2_key.key_name

  user_data = base64encode(templatefile("${path.module}/scripts/k3s-worker.sh", {
    k3s_token     = random_password.k3s_token.result
    master_ip     = aws_instance.k3s_master.private_ip
  }))

  depends_on = [aws_instance.k3s_master]

  tags = {
    Name = "k3s-worker"
    Role = "worker"
  }
}