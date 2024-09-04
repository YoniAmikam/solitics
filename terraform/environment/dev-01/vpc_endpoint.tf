locals {
  vpc_1_ssm_endpoints = "${module.vpc_1.name}-ssm-endpoints"
  vpc_2_ssm_endpoints = "${module.vpc_2.name}-ssm-endpoints"
}

module "vpc_1_ssm_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

  vpc_id = module.vpc_1.vpc_id

  endpoints = {
    for service in toset(["ssm", "ssmmessages", "ec2messages"]) :
    replace(service, ".", "_") => {
      service             = service
      subnet_ids          = slice(module.vpc_1.private_subnets, 0, 2)
      private_dns_enabled = true
      tags                = { Name = "${local.vpc_1_ssm_endpoints}-${service}" }
    }
  }

  create_security_group      = true
  security_group_name_prefix = "${local.vpc_1_ssm_endpoints}-"
  security_group_description = "${local.vpc_1_ssm_endpoints} security group"

  security_group_rules = {
    ingress_https = {
      description = "HTTPS from subnets"
      cidr_blocks = module.vpc_1.private_subnets_cidr_blocks
    }
  }

  tags = local.tags
}

module "vpc_2_ssm_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

  vpc_id = module.vpc_2.vpc_id

  endpoints = {
    for service in toset(["ssm", "ssmmessages", "ec2messages"]) :
    replace(service, ".", "_") => {
      service             = service
      subnet_ids          = slice(module.vpc_2.private_subnets, 0, 2)
      private_dns_enabled = true
      tags                = { Name = "${local.vpc_2_ssm_endpoints}-${service}" }
    }
  }

  create_security_group      = true
  security_group_name_prefix = "${local.vpc_2_ssm_endpoints}-"
  security_group_description = "${local.vpc_2_ssm_endpoints} security group"

  security_group_rules = {
    ingress_https = {
      description = "HTTPS from subnets"
      cidr_blocks = module.vpc_2.private_subnets_cidr_blocks
    }
  }

  tags = local.tags
}
