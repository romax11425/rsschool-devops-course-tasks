# Bastion Host
resource "aws_instance" "bastion" {
  ami                    = "ami-0694d931cee176e7d" # Amazon Linux 2023 AMI in eu-west-1
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = aws_key_pair.task2_key.key_name

  user_data = <<-EOF
    #!/bin/bash
    # Update system
    dnf update -y
    
    # Install fail2ban to protect against brute force attacks
    dnf install -y fail2ban
    
    # Configure fail2ban for SSH
    cat > /etc/fail2ban/jail.local <<'EOT'
    [sshd]
    enabled = true
    bantime = 3600
    maxretry = 3
    findtime = 600
    EOT
    
    # Start fail2ban
    systemctl enable fail2ban
    systemctl start fail2ban
    
    # Harden SSH configuration
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd
    
    # Install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
    
    # Create .kube directory for ec2-user
    mkdir -p /home/ec2-user/.kube
    chown ec2-user:ec2-user /home/ec2-user/.kube
  EOF

  tags = {
    Name = "Bastion-Host"
  }
}