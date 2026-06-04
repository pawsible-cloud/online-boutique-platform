variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "online-boutique-cluster"
}

variable "cluster_version" {
  description = "Kubernetes Version"
  type        = string
  default     = "1.31"
}

variable "node_instance_type" {
  description = "Worker Node Instance Type"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_count" {
  type    = number
  default = 1
}

variable "node_min_count" {
  type    = number
  default = 1
}

variable "node_max_count" {
  type    = number
  default = 2
}

variable "services" {
  type = list(string)

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
