module "cloudfront_1" {
  source = "terraform-aws-modules/cloudfront/aws"
  aliases = [
    "cf.${var.domain_name}",
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

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = false

    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
  }

  depends_on = [null_resource.alb_1_ready]
}
