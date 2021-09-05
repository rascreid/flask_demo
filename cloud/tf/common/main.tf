provider "aws" {
  region  = var.aws_region
  default_tags {
    tags = {
      "Environment" = var.environment_type
      "App"         = var.component_name
      "Owner"       = var.owner
    }
  }
}

terraform {
  backend "s3" {}
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "default-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = false
  single_nat_gateway = false
  one_nat_gateway_per_az = false

  # map_public_ip_on_launch = false

  tags = {
    Terraform = true
  }
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${var.component_name}-tfstate-${var.environment_type}-${var.aws_region}"
  acl    = "private"
  force_destroy = true

  versioning = {
    enabled = true
  }
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}

module "dynamodb_table" {
  # source = "terraform-aws-modules/dynamodb-table/aws"
  # local module as example
  source = "../modules/terraform-aws-dynamodb-table"

  name      = "${var.component_name}-tfstate-lock-${var.environment_type}-${var.aws_region}"
  hash_key  = "LockID"
  # create_table = false

  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]
}

module "ecr" {
  source = "lgallard/ecr/aws"

  count                = length(local.ecr_repos)
  name                 = "${local.resource_prefix}/${local.ecr_repos[count.index]}"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
  tags = {
    Terraform   = true
  }
}

module "iam-ec2" {
  source  = "../modules/iam-ec2"

  resource_prefix = local.resource_prefix
  abbr_region     = local.abbr_region
  name            = "${local.resource_prefix}-${local.abbr_region}-ec2_role"
}

module "iam-ecs" {
  source  = "../modules/iam-ecs"

  name          = "${local.resource_prefix}-${local.abbr_region}-ecs_task_execution_role"
}

module "iam-codedeploy" {
  source  = "../modules/iam-codedeploy"

  name            = "${local.resource_prefix}-${local.abbr_region}-codedeploy_role"
}
