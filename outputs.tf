output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions_oidc.arn
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.tf_state_lock.arn
}

output "S3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.tf_state.id
}