# terraform/main.tf

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
  
  # Store Terraform state in S3 so your team shares the same state
  # Create this S3 bucket manually FIRST (see 9.2)
  backend "s3" {
    bucket = "online-boutique-tf-state-720035686687"   # Change this
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}
# trigger
# trigger
# trigger
