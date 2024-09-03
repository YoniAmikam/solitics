module "wafv2_cloudfront" {
  source  = "aws-ss/wafv2/aws"
  version = "3.2.0"

  providers = {
    aws = aws.cloudfront-global
  }

  enabled_web_acl_association = true
  resource_arn                = []

  enabled_logging_configuration = false

  name           = "cloudfront-waf"
  scope          = "CLOUDFRONT"
  default_action = "allow"
  rule = [
    {
      name     = "block-selected-countries"
      priority = 10
      action   = "block"
      custom_response = {
        response_code = 404
        response_header = [
          {
            name  = "X-Custom-Response-Header-01"
            value = "Not authorized"
          }
        ]
      }
      geo_match_statement = {
        country_codes = ["CN", "US"]
      }
      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "cloudfront_geo_block"
        sampled_requests_enabled   = false
      }
    }
  ]
  visibility_config = {
    cloudwatch_metrics_enabled = false
    metric_name                = "cloudfront_waf_metric"
    sampled_requests_enabled   = false
  }
  tags = local.tags
}

module "wafv2_application" {
  source  = "aws-ss/wafv2/aws"
  version = "3.2.0"

  enabled_web_acl_association = true
  resource_arn                = []

  enabled_logging_configuration = false

  name           = "application-waf"
  scope          = "REGIONAL"
  default_action = "allow"
  rule = [
    {
      name     = "count-admin-path"
      priority = 10
      action   = "count"
      and_statement = {
        statements = [
          {
            not_statement = {
              byte_match_statement = {
                field_to_match = {
                  uri_path = {}
                }
                positional_constraint = "CONTAINS"
                search_string         = "/admin"
                text_transformation = [
                  {
                    priority = 0
                    type     = "LOWERCASE"
                  }
                ]
              }
            }
          },
          {
            byte_match_statement = {
              field_to_match = {
                uri_path = {}
              }
              positional_constraint = "CONTAINS"
              search_string         = "/administrator"
              text_transformation = [
                {
                  priority = 0
                  type     = "LOWERCASE"
                }
              ]
            }
          }
        ]
      }
      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "application_admin_count"
        sampled_requests_enabled   = false
      }
    }
  ]
  visibility_config = {
    cloudwatch_metrics_enabled = false
    metric_name                = "application_waf_metric"
    sampled_requests_enabled   = false
  }
  tags = local.tags
}
