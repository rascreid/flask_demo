resource "aws_iam_role" "instance_role" {
  name = var.name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.resource_prefix}-${var.abbr_region}-ec2_instance_profile"
  role = aws_iam_role.instance_role.name
}

resource "aws_iam_role_policy_attachment" "policies" {
  count = length(local.iam_policies)
  role       = aws_iam_role.instance_role.name
  policy_arn = local.iam_policies[count.index]
}
