variable "github_repo" {
  description = "GitHub repository path in format 'username/repo'"
  type        = string
  default     = "romax11425/rsschool-devops-course-tasks"
}

variable "S3_bucket_tf_state" {
  description = "S3 bucket for terraform state"
  type        = string
  default     = "rss-tf-state"
}

# IAM variables
variable "github_actions_oidc_url" {
  description = "GitHub Actions OIDC provider URL"
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "github_actions_client_id_list" {
  description = "List of client IDs for GitHub Actions OIDC provider"
  type        = list(string)
  default     = ["sts.amazonaws.com"]
}

variable "github_actions_thumbprint_list" {
  description = "List of thumbprints for GitHub Actions OIDC provider"
  type        = list(string)
  default     = ["2b18947a6a9fc7764fd8b5fb18a863b0c6dac24f"]
}

variable "github_actions_role_name" {
  description = "Name of the IAM role for GitHub Actions"
  type        = string
  default     = "GithubActionsRole"
}

variable "iam_policies" {
  description = "List of IAM policies to attach to the GitHub Actions role"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  ]
}

# network variables

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for the subnets"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "task2-vpc"
}

variable "key_name" {
  description = "Name of the key pair to use for SSH access"
  type        = string
  default     = "task2-key"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0694d931cee176e7d" # Amazon Linux 2023 AMI in eu-west-1
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
  default     = "t2.micro"
}