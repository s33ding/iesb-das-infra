resource "aws_ecr_repository" "app_prod" {
  name = "iesb-das-app-prod"

  tags = {
    Environment = "prod"
  }
}

resource "aws_iam_policy" "students_ecr_policy" {
  name        = "students-ecr-policy"
  description = "ECR access for students excluding prod resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:*"
        ]
        Resource = "*"
        Condition = {
          "ForAllValues:StringNotEquals" = {
            "aws:ResourceTag/Environment" = "prod"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:DescribeRepositories",
          "ecr:ListRepositories"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "students_ecr" {
  user       = aws_iam_user.students.name
  policy_arn = aws_iam_policy.students_ecr_policy.arn
}
