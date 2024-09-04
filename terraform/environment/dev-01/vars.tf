variable "env_name" {
  type    = string
  default = "dev-01"
}

variable "aws_account_id" {
  type    = string
  default = "096432477737"
}

variable "nginx_replicas" {
  type    = number
  default = 3
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "alb_1_name" {
  type    = string
  default = "alb-1"
}

variable "ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "domain_name" {
  type    = string
  default = "sintersoli.com"
}
