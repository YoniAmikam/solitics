resource "helm_release" "nginx" {
  name       = "nginx"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx"

  values = [
    templatefile("./helm_chart/nginx/values.yaml.tftpl", {
      replicas           = var.nginx_replicas
      security_groups_id = aws_security_group.nginx_alb_1_security_group.id
      alb_name           = var.alb_1_name
      ssl_policy         = var.ssl_policy
      hostname           = var.sol_domain_name
      wafv2_arn          = module.wafv2_application.aws_wafv2_arn
      s3_bucket_logs_id   = module.alb_1_log_bucket.s3_bucket_id
    })
  ]

  depends_on = [
    module.eks_1,
    helm_release.aws_load_balancer_controller
  ]
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  values = [
    templatefile("./helm_chart/alb/values.yaml.tftpl", {
      cluster_name            = module.eks_1.cluster_name
      region                  = var.region
      vpc_id                  = module.vpc_1.vpc_id
      alb_controller_role_arn = aws_iam_role.alb_controller_role.arn
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.alb_controller_policy_attach,
    module.eks_1
  ]
}
