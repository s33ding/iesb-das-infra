resource "aws_secretsmanager_secret" "ide_password" {
  name        = "iesb-das/ide-password"
  description = "Password for IDE access"
}

resource "random_password" "ide_password" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret_version" "ide_password" {
  secret_id     = aws_secretsmanager_secret.ide_password.id
  secret_string = jsonencode({
    password = random_password.ide_password.result
  })
}

resource "aws_iam_policy" "secrets_access" {
  name        = "SecretsManagerAccess"
  description = "Allow access to Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.ide_password.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_access" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}
