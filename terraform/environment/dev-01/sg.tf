resource "aws_security_group" "nginx_alb_1_security_group" {
  name        = "nginx_alb_sg"
  description = "Security group for Nginx ALB"
  vpc_id      = module.vpc_1.vpc_id

  tags = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "nginx_alb_1_allow_http_ipv4" {
  security_group_id = aws_security_group.nginx_alb_1_security_group.id
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cloudfront_origin_prefix_list.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "nginx_alb_1_allow_all_egress_ipv4" {
  security_group_id = aws_security_group.nginx_alb_1_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "nginx_alb_1_allow_all_egress_ipv6" {
  security_group_id = aws_security_group.nginx_alb_1_security_group.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

module "security_group_ec2_1" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "sg_ec2_1"
  description = "Security Group for EC2 1"

  vpc_id = module.vpc_1.vpc_id

  egress_rules = ["https-443-tcp"]
  egress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = module.vpc_1.vpc_cidr_block
    }
  ]
  tags = local.tags
}

module "security_group_ec2_2" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "sg_ec2_2"
  description = "Security Group for EC2 2"

  vpc_id = module.vpc_2.vpc_id

  egress_rules = ["https-443-tcp"]
  egress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = aws_security_group.nlb_1_sg.id
      description              = "Allow HTTP traffic on port 80 to the specified source security group"
    }
  ]
  ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = aws_security_group.nlb_1_sg.id
      description              = "Allow HTTP traffic on port 80 to the specified source security group"
    }
  ]
  tags = local.tags
}
