terraform {
  backend "s3" {
    bucket       = "online-boutique-tf-state-720035686687"
    key          = "ecr/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "services" {
  default = [
    "frontend",
    "cartservice",
    "productcatalogservice",
    "currencyservice",
    "paymentservice",
    "shippingservice",
    "emailservice",
    "checkoutservice",
    "recommendationservice",
    "adservice",
    "loadgenerator"
  ]
}

resource "aws_ecr_repository" "services" {
  for_each             = toset(var.services)
  name                 = "online-boutique/${each.key}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = "online-boutique"
    Service = each.key
  }
}

output "ecr_registry" {
  value = {
    for k, v in aws_ecr_repository.services : k => v.repository_url
  }
}
