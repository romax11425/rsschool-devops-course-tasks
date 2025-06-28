output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions_oidc.arn
}

output "S3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.tf_state.id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "nat_gateway_ip" {
  description = "Elastic IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "k3s_master_private_ip" {
  description = "Private IP of the k3s master node"
  value       = aws_instance.k3s_master.private_ip
}

output "k3s_worker_private_ip" {
  description = "Private IP of the k3s worker node"
  value       = aws_instance.k3s_worker.private_ip
}

output "ssh_connection_commands" {
  description = "SSH commands to connect to the instances"
  value = {
    bastion = "ssh -i task2-key.pem ec2-user@${aws_instance.bastion.public_ip}"
    k3s_master = "ssh -i task2-key.pem -o ProxyCommand='ssh -i task2-key.pem -W %h:%p ec2-user@${aws_instance.bastion.public_ip}' ec2-user@${aws_instance.k3s_master.private_ip}"
    k3s_worker = "ssh -i task2-key.pem -o ProxyCommand='ssh -i task2-key.pem -W %h:%p ec2-user@${aws_instance.bastion.public_ip}' ec2-user@${aws_instance.k3s_worker.private_ip}"
  }
}