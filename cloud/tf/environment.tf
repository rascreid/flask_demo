data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["default-vpc"]
  }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.vpc.id
}

data "aws_subnet_ids" "private_subnets" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["*-private-*"]
  }
}

data "aws_subnet" "private_subnet_values" {
  for_each = data.aws_subnet_ids.private_subnets.ids
  id       = each.value
}

data "aws_subnet_ids" "public_subnets" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["*-public-*"]
  }
}

data "aws_subnet" "public_subnet_values" {
  for_each = data.aws_subnet_ids.public_subnets.ids
  id       = each.value
}

data "aws_ami" "amazon" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.*-x86_64-ebs"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

data "aws_iam_role" "ecs_task_exec_role" {
  name = "${local.resource_prefix}-${local.abbr_region}-ecs_task_execution_role"
}

data "aws_iam_role" "codedeploy_role" {
  name = "${local.resource_prefix}-${local.abbr_region}-codedeploy_role"
}
