output "role_name" {
  value = aws_iam_role.instance_role.name
}

output "role_arn" {
  value = aws_iam_role.instance_role.arn
}

output "profile_name" {
  value = aws_iam_instance_profile.instance_profile.name
}
