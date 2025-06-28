# Create SSH key pair for EC2 instances
resource "tls_private_key" "task2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "task2_key" {
  key_name   = "task2-key"
  public_key = tls_private_key.task2_key.public_key_openssh
}

# Save the private key to a local file
resource "local_file" "private_key" {
  content         = tls_private_key.task2_key.private_key_pem
  filename        = "${path.module}/task2-key.pem"
  file_permission = "0600"
}