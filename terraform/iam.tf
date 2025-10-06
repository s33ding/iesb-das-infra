resource "aws_iam_user" "students" {
  name = "students-prof-francisco"
}

resource "aws_iam_access_key" "students" {
  user = aws_iam_user.students.name
}

resource "aws_secretsmanager_secret" "students_credentials" {
  name        = "iesb-das/students-credentials"
  description = "AWS credentials for Prof Francisco's students"
}

resource "aws_secretsmanager_secret_version" "students_credentials" {
  secret_id = aws_secretsmanager_secret.students_credentials.id
  secret_string = jsonencode({
    access_key_id     = aws_iam_access_key.students.id
    secret_access_key = aws_iam_access_key.students.secret
    region            = "us-east-1"
  })
}

resource "aws_iam_user" "prof_francisco" {
  name = "prof-francisco"
}

resource "aws_iam_user_policy_attachment" "students_eks" {
  user       = aws_iam_user.students.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_user_policy_attachment" "prof_eks" {
  user       = aws_iam_user.prof_francisco.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
