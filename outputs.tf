output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions_oidc.arn
}

output "S3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.tf_state.id
}