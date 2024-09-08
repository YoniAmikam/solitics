locals {
  ssm_instance_core_iam_policy = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  user_data                    = <<-EOT
    #!/bin/bash
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    sudo sh -c 'curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | perl -pe "s/^/<center><h1>Availability Zone: /" > /var/www/html/index.html'
  EOT
}

module "ec2_1" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.0"

  name                        = "ec2-1"
  ami                         = var.ec2_ami_id
  subnet_id                   = element(module.vpc_1.private_subnets, 0)
  vpc_security_group_ids      = [module.security_group_ec2_1.security_group_id]
  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 1 instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = local.ssm_instance_core_iam_policy
  }
  tags       = local.tags
  depends_on = [module.vpc_1_ssm_endpoints]
}

module "ec2_2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.0"

  name                        = "ec2-2"
  ami                         = var.ec2_ami_id
  subnet_id                   = element(module.vpc_2.private_subnets, 0)
  vpc_security_group_ids      = [module.security_group_ec2_2.security_group_id]
  user_data_base64            = base64encode(local.user_data)
  user_data_replace_on_change = true
  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 2 instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = local.ssm_instance_core_iam_policy
  }
  tags       = local.tags
  depends_on = [module.vpc_2_ssm_endpoints]
}
