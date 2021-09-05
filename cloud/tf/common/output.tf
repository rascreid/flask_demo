output "s3_bucket_name" {
  value = module.s3_bucket.s3_bucket_id
}

output "dynamodb_table_name" {
  value = module.dynamodb_table.dynamodb_table_id
}

output "ecr_repos_names" {
  value = module.ecr.*.name
}

output "ecr_repos_urls" {
  value = module.ecr.*.repository_url
}
