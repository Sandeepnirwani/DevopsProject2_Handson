terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.67"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.15"

  cluster_name    = "prime-video-cluster"
  cluster_version = "1.30"

  cluster_endpoint_public_access = true

  # EKS Addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }

    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id = module.vpc.vpc_id

  # Using public subnets to avoid NAT Gateway charges
  subnet_ids = module.vpc.public_subnets

  eks_managed_node_groups = {

    prime-node = {

      desired_size = 1
      min_size     = 1
      max_size     = 2

      instance_types = ["t3.small"]

      capacity_type = "SPOT"

      ami_type = "AL2_x86_64"

      disk_size = 20

      tags = {
        Name        = "prime-video-node"
        Environment = "dev"
        Project     = "prime-video"
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "prime-video"
  }
}