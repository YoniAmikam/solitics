module "cloudfront_1" {
  version = "3.4.0"
  source  = "terraform-aws-modules/cloudfront/aws"
  aliases = [
    var.sol_domain_name,
  ]

  comment             = "cloudfront-1"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  retain_on_delete    = false
  wait_for_deployment = false
  web_acl_id          = module.wafv2_cloudfront.aws_wafv2_arn

  viewer_certificate = {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:096432477737:certificate/40f821e9-7b3c-400d-a21d-37a819fa2c20"
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  logging_config = {
    bucket = module.cloudfront_access_logs_bucket.s3_bucket_bucket_domain_name
    prefix = "cloudfront-logs"
  }

  origin = {
    application_load_balancer = {
      domain_name = data.aws_lb.alb_1.dns_name
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "application_load_balancer"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods      = ["GET", "HEAD", "OPTIONS"]
    cached_methods       = ["GET", "HEAD"]
    compress             = true
    use_forwarded_values = false

    cache_policy_id          = "83da9c7e-98b4-4e11-a168-04f0df8e2c65"
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
  }

  depends_on = [null_resource.alb_1_ready]
}
