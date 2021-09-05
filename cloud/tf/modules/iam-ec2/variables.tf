variable "resource_prefix" {
  type        = string
}

variable "name" {
  type        = string
}

variable "abbr_region" {
  type        = string
}

variable use_policies {
  type = bool
  default = true
}

locals {
  role_policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  iam_policies = var.use_policies ? local.role_policies : []
}
