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

# dynamodb variables

variable "dynamodb_table_name" {
  description = "DynamoDB table for terraform state lock"
  type        = string
  default     = "rss-tf-state-lock"
}

variable "billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "DynamoDB hash key"
  type        = string
  default     = "LockID"
}

variable "type" {
  description = "DynamoDB hash key type"
  type        = string
  default     = "S"
}