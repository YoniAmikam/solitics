data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_iam_policy_document" "alb_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks_1.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks_1.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

data "aws_ec2_managed_prefix_list" "cloudfront_origin_prefix_list" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

data "aws_lb" "alb_1" {
  name       = var.alb_1_name
  depends_on = [null_resource.alb_1_ready]
}

data "aws_canonical_user_id" "current" {}

data "aws_cloudfront_log_delivery_canonical_user_id" "cloudfront" {}

data "aws_caller_identity" "current" {}