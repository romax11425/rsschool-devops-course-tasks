resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = var.github_actions_oidc_url
  client_id_list  = var.github_actions_client_id_list
  thumbprint_list = var.github_actions_thumbprint_list
}

resource "aws_iam_role" "github_actions_oidc" {
  name = var.github_actions_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "full_access" {
  for_each   = toset(var.iam_policies)
  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = each.value
}