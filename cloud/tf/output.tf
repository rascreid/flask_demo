output "alb_target_group_names" {
  value = module.alb.target_group_names
}

output "alb_target_group_arns" {
  value = module.alb.target_group_arns
}

output "alb_http_tcp_listener_arns" {
  value = module.alb.http_tcp_listener_arns
}

output "alb_direct_url" {
  value = module.alb.lb_dns_name
}
