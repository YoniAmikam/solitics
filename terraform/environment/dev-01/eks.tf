module "eks_1" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "eks-1"
  cluster_version = "1.30"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = module.vpc_1.vpc_id
  subnet_ids               = slice(module.vpc_1.private_subnets, 0, 2)
  control_plane_subnet_ids = slice(module.vpc_1.private_subnets, 2, 4)

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    node-group-1 = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]

      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }

  node_security_group_additional_rules = {
    ingress_alb_1_tcp = {
      description              = "Access EKS from alb-1"
      protocol                 = "tcp"
      from_port                = 8080
      to_port                  = 8080
      type                     = "ingress"
      source_security_group_id = aws_security_group.nginx_alb_1_security_group.id
    }
  }

  enable_cluster_creator_admin_permissions = true

  access_entries = {
    admin = {
      principal_arn = aws_iam_role.eks_roles["eks_admin_role"].arn

      policy_associations = {
        admin_policy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            namespaces = ["*"]
            type       = "namespace"
          }
        }
      }
    }

    read_only = {
      kubernetes_groups = []
      principal_arn     = aws_iam_role.eks_roles["eks_read_only_role"].arn

      policy_associations = {
        read_only_policy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["*"]
            type       = "namespace"
          }
        }
      }
    }

    read_only_default_namespace = {
      kubernetes_groups = []
      principal_arn     = aws_iam_role.eks_roles["eks_read_only_ns_default"].arn

      policy_associations = {
        read_only_default_policy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
      }
    }
  }

  tags = local.tags
}
