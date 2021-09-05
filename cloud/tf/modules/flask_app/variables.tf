variable "cluster_id" {
  description = "The ECS cluster ID"
  type        = string
}

variable "component_name" {
  type        = string
}

variable "container_port" {
  type        = number
}

variable "host_port" {
  type        = number
}

variable "aws_region" {
  type        = string
  default     = ""
}

variable "resource_prefix" {
  type        = string
}

variable "target_group_arn" {
  type        = string
}

variable "execution_role_arn" {
  type        = string
}

variable "desired_count" {
  type        = string
}
