locals {
  eks_iam_roles = {
    eks_admin_role           = "kubeAdmin"
    eks_read_only_role       = "kubeReadOnly"
    eks_read_only_ns_default = "kubeReadOnlyDefaultNS"
  }
}

resource "aws_iam_role" "eks_roles" {
  for_each = local.eks_iam_roles

  name = each.value

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id}:root"
        },
        Action    = "sts:AssumeRole",
        Condition = {}
      }
    ],
  })
}

resource "aws_iam_role" "alb_controller_role" {
  name               = "${module.eks_1.cluster_name}-alb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.alb_controller_assume_role_policy.json
  depends_on         = [module.eks_1]
}

resource "aws_iam_role_policy_attachment" "alb_controller_policy_attach" {
  policy_arn = aws_iam_policy.alb_controller_policy.arn
  role       = aws_iam_role.alb_controller_role.name
}

resource "aws_iam_policy" "alb_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "IAM policy for the AWS Load Balancer Controller"
  policy      = file("./helm_chart/alb/iam_policy.json")
}
