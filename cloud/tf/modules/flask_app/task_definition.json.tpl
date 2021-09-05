[
  {
    "name": "${name}",
    "image": "182851769987.dkr.ecr.us-east-1.amazonaws.com/flask-dev/flask-dev:latest@${aws_ecr_image_digest}",
    "memory": 256,
    "cpu": 256,
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": ${host_port},
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group_name}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "${stream_prefix_name}"
      }
    }
  }
]
