data "aws_ecr_image" "image" {
  repository_name = "flask-dev/flask-dev"
  image_tag       = "latest"
}

data "template_file" "task_definition_template" {
  template = file("${path.module}/task_definition.json.tpl")
  vars = {
    name = var.component_name
    aws_ecr_image_digest = data.aws_ecr_image.image.image_digest
    container_port = var.container_port
    host_port = var.host_port
    region = var.aws_region
    log_group_name = "${var.resource_prefix}-lg"
    stream_prefix_name = var.component_name
  }
}


### If you want to use separate Log group
# resource "aws_cloudwatch_log_group" "cw_log_group" {
#   name              = "flask_app"
#   retention_in_days = 1
# }

resource "aws_ecs_task_definition" "task_definition" {
  family = "flask_app"
  container_definitions = data.template_file.task_definition_template.rendered
  execution_role_arn    = var.execution_role_arn
  network_mode          = "bridge"
}

resource "aws_ecs_service" "service" {
  name            = "flask_app"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = var.desired_count

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.component_name
    container_port   = var.container_port
  }
  force_new_deployment = true
  # that requires + 100% instances free or ASG connected here, but ASG doesn't work now (see Capacity Provider issue)
  scheduling_strategy  = "REPLICA"
  wait_for_steady_state = true
  # deployment_controller {
  #   type = "CODE_DEPLOY"
  # }
  # lifecycle {
  #   ignore_changes = [
  #     load_balancer,
  #     desired_count,
  #     task_definition,
  #     capacity_provider_strategy,
  #   ]
  # }
  lifecycle {
    ignore_changes = [
      load_balancer,
    ]
  }

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
}
