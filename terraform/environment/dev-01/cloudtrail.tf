resource "aws_cloudtrail" "api_activity_trail" {
  name                          = "api-activity-trail"
  s3_bucket_name                = module.cloudtrail_logs_s3_bucket.s3_bucket_id
  s3_key_prefix                 = "prefix"
  include_global_service_events = true
}