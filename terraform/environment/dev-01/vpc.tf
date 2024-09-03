locals {
  vpc_1_cidr            = "192.168.0.0/16"
  vpc_1_private_subnets = [for k, v in range(4) : cidrsubnet(local.vpc_1_cidr, 8, k)]
  vpc_1_public_subnets  = [for k, v in range(2) : cidrsubnet(local.vpc_1_cidr, 8, k + 4)]

  vpc_2_cidr            = "10.0.0.0/16"
  vpc_2_private_subnets = [for k, v in range(4) : cidrsubnet(local.vpc_2_cidr, 8, k)]
  vpc_2_public_subnets  = [for k, v in range(2) : cidrsubnet(local.vpc_2_cidr, 8, k + 4)]

  azs = slice(data.aws_availability_zones.available.names, 0, 2)
  default_network_acl_rules = [
    {
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 80
      protocol   = "tcp"
      rule_no    = 100
      to_port    = 80
    },
    {
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 1024
      protocol   = "tcp"
      rule_no    = 101
      to_port    = 65535
    },
    {
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 443
      protocol   = "tcp"
      rule_no    = 102
      to_port    = 443
    },
    {
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 53
      protocol   = "tcp"
      rule_no    = 103
      to_port    = 53
    },
  ]
}

module "vpc_1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "vpc-1"
  cidr = local.vpc_1_cidr

  azs             = local.azs
  private_subnets = local.vpc_1_private_subnets
  public_subnets  = local.vpc_1_public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  manage_default_network_acl  = true
  default_network_acl_egress  = local.default_network_acl_rules
  default_network_acl_ingress = local.default_network_acl_rules

  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true

  vpc_flow_log_iam_role_name              = "vpc-iam-role"
  vpc_flow_log_iam_role_use_name_prefix   = true
  vpc_flow_log_iam_policy_name            = "vpc-iam-policy"
  vpc_flow_log_iam_policy_use_name_prefix = true

  flow_log_max_aggregation_interval         = 60
  flow_log_cloudwatch_log_group_name_prefix = "/aws/vpc-flow-logs/"
  flow_log_cloudwatch_log_group_name_suffix = "log-group"
  flow_log_cloudwatch_log_group_class       = "INFREQUENT_ACCESS"

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = local.tags
}

module "vpc_2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "vpc-2"
  cidr = local.vpc_2_cidr

  azs             = local.azs
  private_subnets = local.vpc_2_private_subnets
  public_subnets  = local.vpc_2_public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  manage_default_network_acl  = true
  default_network_acl_egress  = local.default_network_acl_rules
  default_network_acl_ingress = local.default_network_acl_rules

  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true

  vpc_flow_log_iam_role_name              = "secondary-vpc-iam-role"
  vpc_flow_log_iam_role_use_name_prefix   = true
  vpc_flow_log_iam_policy_name            = "secondary-vpc-iam-policy"
  vpc_flow_log_iam_policy_use_name_prefix = true

  flow_log_max_aggregation_interval         = 60
  flow_log_cloudwatch_log_group_name_prefix = "/aws/secondary-vpc-flow-logs/"
  flow_log_cloudwatch_log_group_name_suffix = "log-group"
  flow_log_cloudwatch_log_group_class       = "INFREQUENT_ACCESS"

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = local.tags
}