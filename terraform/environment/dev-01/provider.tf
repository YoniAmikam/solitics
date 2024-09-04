locals {
  tags = {
    Terraform         = "true"
    Environment       = var.env_name
    AWS_account_alias = var.aws_account_id
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}

provider "aws" {
  alias  = "cloudfront-global"
  region = "us-east-1"
}

provider "helm" {
  kubernetes {
    host                   = module.eks_1.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_1.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks_1.cluster_name]
      command     = "aws"
    }
  }
}
