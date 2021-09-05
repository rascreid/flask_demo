variable "metric_filters" {
  description = "Schema list of metric filters, consisting of name, filter_pattern, log_group_name, and metric_transformation schema"
  type = list(object({
    name           = string
    filter_pattern = string
    log_group_name = string
    metric_transformation = object({
      name          = string
      namespace     = string
      value         = string
      default_value = string
    })
  }))
  default = []
}
