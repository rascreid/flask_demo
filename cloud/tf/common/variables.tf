variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "eu-west-1"
}

variable "component_name" {
  type        = string
  description = "Application Prefix"
  default     = "r-flask"
}

variable "environment_type" {
  type        = string
  description = "Type of environment they are deployed into"
  default     = "dev"
}

variable abbr_regions {
  type = map
  default = {
    "us-east-1" = "use1"
    "eu-west-1" = "euw1"
    "ap-southeast-1" = "apse1"
  }
}

variable owner {
  type    = string
}

variable ecrs {
  type    = list
}


locals {
  resource_prefix   = "${var.component_name}-${var.environment_type}"
  abbr_region       = var.abbr_regions[var.aws_region]
  ecr_repos         = var.ecrs
}
