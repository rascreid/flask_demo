/*====================================================================
      AWS CodeDeploy integration for Blue/Green Deployments.
====================================================================*/

# // AWS Codedeploy apps defintion for each module
# resource "aws_codedeploy_app" "main" {
#   compute_platform = "ECS"
#   name             = "Deployment-${var.component_name}"
# }
#
# resource "aws_codedeploy_deployment_group" "main" {
#   count = 1
#   app_name               = aws_codedeploy_app.main.name
#   deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
#   deployment_group_name  = "deployment-group-${var.component_name}"
#   service_role_arn       = data.aws_iam_role.codedeploy_role.arn
#
#   auto_rollback_configuration {
#     enabled = true
#     events  = ["DEPLOYMENT_FAILURE"]
#   }
#   blue_green_deployment_config {
#     deployment_ready_option {
#       action_on_timeout = "CONTINUE_DEPLOYMENT"
#     }
#
#     terminate_blue_instances_on_deployment_success {
#       action            = "TERMINATE"
#     }
#   }
#
#   deployment_style {
#     deployment_option = "WITH_TRAFFIC_CONTROL"
#     deployment_type   = "BLUE_GREEN"
#   }
#
#   ecs_service {
#     cluster_name = module.ecs.ecs_cluster_name
#     # service_name = aws_ecs_service.main[count.index].name
#     # service_name = "flask_app"
#     service_name = module.flask_app.ecs_service_name
#   }
#
#   load_balancer_info {
#     target_group_pair_info {
#       prod_traffic_route {
#         listener_arns = [
#           module.alb.http_tcp_listener_arns[0]]
#       }
#       test_traffic_route {
#         listener_arns = [
#           module.alb.http_tcp_listener_arns[1]]
#       }
#       target_group {
#         name = module.alb.target_group_names[0]
#       }
#       target_group {
#         name = module.alb.target_group_names[1]
#       }
#     }
#   }
#   # trigger_configuration {
#   #   trigger_events = [
#   #     "DeploymentSuccess",
#   #     "DeploymentFailure",
#   #   ]
#   #
#   #   trigger_name       = data.external.commit_message.result["message"]
#   #   trigger_target_arn = var.sns_topic_arn
#   # }
#
#   lifecycle {
#     ignore_changes = [blue_green_deployment_config]
#   }
# }
