# Save the private key to a local file
resource "local_file" "private_key" {
  content         = tls_private_key.task2_key.private_key_pem
  filename        = "${path.module}/task2-key.pem"
  file_permission = "0600"
}