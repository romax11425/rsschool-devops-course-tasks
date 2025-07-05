# Bastion Host
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.bastion_instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = aws_key_pair.task2_key.key_name

  user_data = base64encode(templatefile("${path.module}/bastion-userdata.sh", {
    master_ip = aws_instance.k3s_master.private_ip
    ssh_key   = tls_private_key.task2_key.private_key_pem
  }))

  depends_on = [aws_instance.k3s_master]

  tags = {
    Name = "Bastion-Host"
  }
}