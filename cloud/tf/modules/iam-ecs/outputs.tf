output "role_name" {
  value = aws_iam_role.ecs_task_execution_role.name
}

output "role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}
