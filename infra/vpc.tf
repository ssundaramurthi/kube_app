variable "region" {
  default     = "ap-southeast-2"
  description = "AWS region"
}

data "aws_availability_zones" "available" {}


provider "aws" {
  profile = "senthils"
  region  = "ap-southeast-2"
}

locals {
  cluster_name = "cp-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.66.0"

  name                 = "primary-vpc"
  cidr                 = "192.168.0.0/22"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["192.168.2.0/25", "192.168.2.128/25", "192.168.3.0/25"]
  public_subnets       = ["192.168.0.0/25", "192.168.0.128/25", "192.168.1.0/25"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
