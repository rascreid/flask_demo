data "template_file" "dashboard" {
 template = file("${path.module}/dashboard_body.json")
 vars = {
   aws_region = var.aws_region
   ecs_cluster_name = var.ecs_cluster_name
   metric_namespace = var.metric_namespace
 }
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.resource_prefix}-metrics"
  dashboard_body = data.template_file.dashboard.rendered
}
