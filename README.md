# AWS Infrastructure with Terraform

This repository contains Terraform configuration for setting up a secure AWS infrastructure with VPC, subnets, bastion host, and S3 bucket for remote state management. It also includes GitHub Actions workflow for CI/CD automation.

## Infrastructure Components

- **VPC**: A custom VPC with public and private subnets across two availability zones
- **Networking**: Internet Gateway, NAT Gateway, route tables, and network ACLs
- **Security**: Security groups for bastion host and private instances
- **Compute**: Bastion host for secure SSH access to private instances
- **Storage**: S3 bucket with versioning and encryption for Terraform state
- **IAM**: GitHub Actions OIDC integration for secure CI/CD

## File Structure

- `providers.tf` - AWS provider configuration
- `variables.tf` - All input variables for the infrastructure
- `outputs.tf` - Output values from the infrastructure
- `main.tf` - Core Terraform configuration
- `vpc.tf` - VPC and subnet resources
- `routing.tf` - Route tables, Internet Gateway, and NAT Gateway
- `security.tf` - Security groups for instances
- `network_acls.tf` - Network ACLs for subnets
- `bastion.tf` - Bastion host configuration
- `s3_bucket.tf` - S3 bucket for Terraform state
- `iam.tf` - IAM roles and policies for GitHub Actions
- `data.tf` - Data sources for AWS account and region
- `backend.tf` - S3 backend configuration

## Requirements

- Terraform = 1.12.2
- AWS provider ~> 5.0
- TLS provider ~> 4.0
- Local provider ~> 2.4
- AWS credentials with appropriate permissions

## Usage

1. Clone the repository
2. Initialize Terraform:
   ```
   terraform init
   ```
3. Review the plan:
   ```
   terraform plan
   ```
4. Apply the configuration:
   ```
   terraform apply
   ```

## GitHub Actions Integration

This repository includes a GitHub Actions workflow that automates the Terraform deployment process. The workflow uses OIDC for secure authentication with AWS without storing long-lived credentials.