output "metric_filters" {
  description = "Maps of name => filter objects"
  value       = aws_cloudwatch_log_metric_filter.this
}
