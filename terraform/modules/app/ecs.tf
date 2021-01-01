resource "aws_ecs_cluster" "app" {
  name = "${var.environment}_app"

  tags = {
    "Name"        = "${var.environment}_app"
    "Environment" = var.environment
  }
}

locals {
  task_environment = jsonencode([
    for k, v in var.server_envs:
    { name = k, value = v }
  ])

  task_secrets = jsonencode([
    for key in var.server_secrets:
    { name = key, valueFrom = "${upper(var.environment)}_${key}" }
  ])
}

resource "aws_ecs_task_definition" "app_web" {
  family                   = "${var.environment}_app_web_task"
  task_role_arn            = aws_iam_role.ecs_role.arn
  execution_role_arn       = aws_iam_role.ecs_role.arn
  network_mode             = "awsvpc"
  memory                   = var.ecs.web.memory
  cpu                      = var.ecs.web.cpu
  requires_compatibilities = ["FARGATE"]

  container_definitions = <<TASK
[
  {
    "name": "web",
    "image": "${var.ecs.web.ecr_image}",
    "essential": true,
    "memory": ${ceil(var.ecs.web.memory * 0.9)},
    "portMappings": [
      {
        "containerPort": ${var.ecs.web.container_port},
        "protocol": "tcp",
        "hostPort": ${var.ecs.web.host_port}
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "secretOptions": null,
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.ecs_web.name}",
        "awslogs-region": "${var.region.name}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "environment": ${local.task_environment},
    "secrets": ${local.task_secrets}
  }
]
TASK
}
