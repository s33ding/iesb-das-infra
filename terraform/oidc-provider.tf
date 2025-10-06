data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.development_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.development_cluster.identity[0].oidc[0].issuer
}
