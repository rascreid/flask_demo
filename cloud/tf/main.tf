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
  backend "s3" {
    # bucket = "flask-tfstate-dev-use1"
    # key    = "tf_states/terraform.tfstate"
    # region  = "eu-west-1"
    #
    # dynamodb_table = "flask-tfstate-lock-dev-use1"
    # encrypt = true
  }
}

module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "main-sg"
  description = "allow 80 and 8080"
  vpc_id      = data.aws_vpc.vpc.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp","http-8080-tcp"]
}

data "template_file" "init" {
  template = file("${path.module}/init.tpl")

  vars = {
    username        = "${var.component_name}-dev"
    resource_prefix = local.resource_prefix
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  # Autoscaling group
  name                      = "${local.resource_prefix}-asg"
  use_name_prefix           = false
  min_size                  = 1
  max_size                  = 10
  desired_capacity          = 4
  vpc_zone_identifier       = [for s in data.aws_subnet.public_subnet_values: s.id]
  health_check_grace_period = 120
  health_check_type         = "EC2"
  force_delete              = true
  protect_from_scale_in     = true

  # Launch configuration
  use_lc                    = true
  create_lc                 = true
  lc_name                   = "${local.resource_prefix}"
  lc_use_name_prefix        = true
  image_id                  = data.aws_ami.amazon.image_id
  instance_type             = var.instance_type
  iam_instance_profile_name = "${local.resource_prefix}-${local.abbr_region}-ec2_instance_profile"
  security_groups           = [data.aws_security_group.default.id, module.sg.security_group_id]
  # associate_public_ip_address = false
  root_block_device = [
    {
	    volume_size = "30"
	    volume_type = "gp2"
	    encrypted = "true"
	  }
  ]
  user_data                 = data.template_file.init.rendered
  # user_data                 = "#!/bin/bash\nmkdir -p /etc/ecs\necho ECS_CLUSTER=${local.resource_prefix}-cluster >> /etc/ecs/ecs.config"

  tags = [
    {
      key                 = "Name"
      value               = "${local.resource_prefix}-ec2"
      propagate_at_launch = true
    }
  ]
  tags_as_map = {
    "Environment"      = var.environment_type
    "App"              = var.component_name
    "Owner"            = var.owner
    "AmazonECSManaged" = ""
  }
}

# resource "aws_ecs_capacity_provider" "prov1" {
#   name = "prov1"
#   auto_scaling_group_provider {
#     auto_scaling_group_arn = module.asg.autoscaling_group_arn
#     managed_termination_protection = "ENABLED"
#
#     managed_scaling {
#       maximum_scaling_step_size = 1000
#       minimum_scaling_step_size = 1
#       status                    = "ENABLED"
#       target_capacity           = 10
#     }
#   }
# }

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "${local.resource_prefix}-alb"

  load_balancer_type = "application"

  vpc_id             = data.aws_vpc.vpc.id
  subnets            = data.aws_subnet_ids.public_subnets.ids
  security_groups    = [data.aws_security_group.default.id, module.sg.security_group_id]


  target_groups = [
    {
      name_prefix      = "blue-"
      backend_protocol = "HTTP"
      backend_port     = 5000
      health_check = {
        enabled  = true
        protocol = "HTTP"
        path     = "/signin/"
        matcher  = "200"
      }
    },
    {
      name_prefix      = "green-"
      backend_protocol = "HTTP"
      backend_port     = 5000
      health_check = {
        enabled  = true
        protocol = "HTTP"
        path     = "/signin/"
        matcher  = "200"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      action_type        = "forward"
      # target_group_arn   = aws_lb_target_group.blue.arn
      target_group_index = 0
    },
    {
      port               = 8080
      protocol           = "HTTP"
      action_type        = "forward"
      # target_group_arn   = aws_lb_target_group.blue.arn
      target_group_index = 1
    }
  ]

  tags = {
    Terraform = true
  }
}

module "log_group" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "~> 2.0"

  name              = "${local.resource_prefix}-lg"
  retention_in_days = 60
}

module "sns_topic" {
  source  = "terraform-aws-modules/sns/aws"
  version = "~> 3.0"

  name  = "example-topic"
}

locals {
  metric_transformation_namespace = "${local.resource_prefix}-metrics"
}

module "log_metric_filter" {
  source  = "./modules/cw_log_metric_filter"

  metric_filters = [
    {
      name           = "metric-2xx-${module.log_group.cloudwatch_log_group_name}"
      filter_pattern = "[..., status_code=2*,]"
      log_group_name = module.log_group.cloudwatch_log_group_name
      metric_transformation = {
        name          = "2xxCount"
        namespace     = local.metric_transformation_namespace
        value         = 1
        default_value = null
      }
    },
    {
      name           = "metric-4xx-${module.log_group.cloudwatch_log_group_name}"
      filter_pattern = "[..., status_code=4*,]"
      log_group_name = module.log_group.cloudwatch_log_group_name
      metric_transformation = {
        name          = "4xxCount"
        namespace     = local.metric_transformation_namespace
        value         = 1
        default_value = null
      }
    },
    {
      name           = "metric-5xx-${module.log_group.cloudwatch_log_group_name}"
      filter_pattern = "[..., status_code=5*,]"
      log_group_name = module.log_group.cloudwatch_log_group_name
      metric_transformation = {
        name          = "5xxCount"
        namespace     = local.metric_transformation_namespace
        value         = 1
        default_value = null
      }
    }
  ]
}

module "metric_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 2.0"

  alarm_name          = "my-application-logs-errors"
  alarm_description   = "Bad errors in my-application-logs"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 10
  period              = 60

  namespace   = local.metric_transformation_namespace
  metric_name = "4xxCount"
  statistic   = "SampleCount"

  alarm_actions = ["arn:aws:sns:us-east-1:182851769987:example-topic"]
}

module "cloudwatch_dashboard" {
  source  = "./modules/cw_dashboard"

  resource_prefix           = local.resource_prefix
  aws_region                = var.aws_region
  ecs_cluster_name          = module.ecs.ecs_cluster_name
  # ecs_cluster_name          = "${local.resource_prefix}-cluster"
  # metric_2xx                = "metric-2xx-${module.log_group.cloudwatch_log_group_name}"
  metric_namespace          = local.metric_transformation_namespace
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 3.0"
  depends_on = [module.alb]

  container_insights = true

  # capacity_providers = [aws_ecs_capacity_provider.prov1.name]
  # default_capacity_provider_strategy = [{
  #   capacity_provider = aws_ecs_capacity_provider.prov1.name
  #   weight            = "1"
  # }]

  name = "${local.resource_prefix}-cluster"
  tags = {
    Name = "${local.resource_prefix}-cluster"
    Terraform = true
  }
}

#----- ECS  Services--------
module "flask_app" {
  source = "./modules/flask_app"

  cluster_id                = module.ecs.ecs_cluster_id
  component_name            = var.component_name
  container_port            = 5000
  host_port                 = 5000
  desired_count             = 2
  aws_region                = var.aws_region
  resource_prefix           = local.resource_prefix
  # target_group_arn          = module.alb.target_group_arns[0] # port 80
  target_group_arn          = module.alb.target_group_arns[1] # port 8080
  execution_role_arn        = data.aws_iam_role.ecs_task_exec_role.arn
}
