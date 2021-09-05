locals {
  metric_filters = { for filter in var.metric_filters : filter.name => filter }
}

resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each = local.metric_filters

  name           = each.value["name"]
  pattern        = each.value["filter_pattern"]
  log_group_name = each.value["log_group_name"]

  metric_transformation {
    name          = each.value["metric_transformation"].name
    namespace     = each.value["metric_transformation"].namespace
    value         = each.value["metric_transformation"].value
    default_value = each.value["metric_transformation"].default_value
  }
}
