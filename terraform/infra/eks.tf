# terraform/eks.tf
# Creates the EKS cluster and worker node group

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Place the cluster in the VPC we created
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true  # Allow kubectl from your laptop

  # Worker nodes configuration
  eks_managed_node_groups = {
    main = {
      name = "main-nodes"
      
      instance_types = [var.node_instance_type]
      
      min_size     = var.node_min_count
      max_size     = var.node_max_count
      desired_size = var.node_desired_count

      # Use the latest EKS-optimised Amazon Linux 2 AMI
      ami_type = "AL2_x86_64"
    }
  }

  # Allow nodes to pull images from ECR
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  tags = {
    Project = "online-boutique"
  }
}

# Allow your current IAM user/role to access the cluster
data "aws_caller_identity" "current" {}
