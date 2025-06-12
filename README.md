# rsschool-devops-course-tasks

Terraform configuration for AWS infrastructure that sets up S3 bucket and DynamoDB table for remote state management. Includes GitHub Actions workflow for CI/CD automation.

## Components
- S3 bucket with versioning and encryption for state storage
- DynamoDB table for state locking
- GitHub Actions workflow for automated testing and deployment

## Requirements
- Terraform >= 1.10
- AWS credentials with appropriate permissions