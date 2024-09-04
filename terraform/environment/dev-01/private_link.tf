resource "aws_security_group" "nlb_1_sg" {
  vpc_id = module.vpc_2.vpc_id
  name   = "nlb-1-sg"

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc_2.vpc_cidr_block]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc_1.vpc_cidr_block]
  }
}

resource "aws_lb" "nlb_1" {
  name               = "nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = distinct([module.vpc_2.private_subnets[0], module.vpc_2.private_subnets[1]])
  security_groups    = [aws_security_group.nlb_1_sg.id]
}

resource "aws_lb_target_group" "nlb_1_tg" {
  name        = "nlb-1-tg"
  port        = 80
  protocol    = "TCP"
  vpc_id      = module.vpc_2.vpc_id
  target_type = "ip"
}

resource "aws_lb_target_group_attachment" "nlb_1_tg_attachment" {
  target_group_arn = aws_lb_target_group.nlb_1_tg.arn
  target_id        = module.ec2_2.private_ip
  port             = 80
}

resource "aws_lb_listener" "nlb_1_listener" {
  load_balancer_arn = aws_lb.nlb_1.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_1_tg.arn
  }
}

resource "aws_vpc_endpoint_service" "vpc_1_to_vpc_2_endpoint_service" {
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.nlb_1.arn]
  supported_ip_address_types = ["ipv4"]
  tags = merge(
    local.tags,
    {
      "Name" = "vpc-1-to-vpc_2-endpoint-service"
    }
  )
}

resource "aws_security_group" "vpc_1_endpoint_sg" {
  vpc_id = module.vpc_1.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc_1.vpc_cidr_block]
  }
}

resource "aws_vpc_endpoint" "vpc_1_endpoint" {
  vpc_id              = module.vpc_1.vpc_id
  service_name        = aws_vpc_endpoint_service.vpc_1_to_vpc_2_endpoint_service.service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [element(module.vpc_1.private_subnets, 0)]
  private_dns_enabled = false

  security_group_ids = [aws_security_group.vpc_1_endpoint_sg.id]
  tags = merge(
    local.tags,
    {
      "Name" = "vpc-1-endpoint"
    }
  )
}
