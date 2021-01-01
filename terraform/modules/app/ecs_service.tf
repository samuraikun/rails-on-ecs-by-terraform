resource "aws_service_discovery_private_dns_namespace" "app_web" {
  name        = "${var.environment}_app_web"
  description = "App Web Service in ${var.environment}"
  vpc         = var.vpc.vpc.id
}

resource "aws_service_discovery_service" "app_web" {
  name = "${var.environment}_app_web"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.app_web.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_ecs_service" "app_web" {
  name                               = "${var.environment}_app_web_service"
  cluster                            = aws_ecs_cluster.app.id
  task_definition                    = aws_ecs_task_definition.app_web.arn
  platform_version                   = "1.4.0"
  desired_count                      = var.ecs.web.desired_count
  launch_type                        = "FARGATE"
  deployment_minimum_healthy_percent = var.ecs.web.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.ecs.web.deployment_maximum_percent
  health_check_grace_period_seconds  = "120"

  depends_on = [aws_lb.app_web]

  load_balancer {
    target_group_arn = aws_lb_target_group.app_web.arn
    container_name   = "web"
    container_port   = var.ecs.web.host_port
  }

  network_configuration {
    subnets          = var.vpc.subnet_private[*].id
    security_groups  = [var.vpc.security_group_web.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.app_web.arn
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition
    ]
  }
}

resource "aws_appautoscaling_target" "app_web_scale" {
  service_namespace  = "ecs"
  max_capacity       = var.ecs.web.max_capacity
  min_capacity       = var.ecs.web.min_capacity
  resource_id        = "service/${aws_ecs_cluster.app.name}/${aws_ecs_service.app_web.name}"
  scalable_dimension = "ecs:service:DesiredCount"
}

locals {
  metric_name = ["cpu", "memory"]
}

resource "aws_appautoscaling_policy" "app_web_scale_out" {
  count              = length(local.metric_name)
  name               = "${var.environment}_app_web_scale_out_${local.metric_name[count.index]}"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.app_web_scale.resource_id
  scalable_dimension = aws_appautoscaling_target.app_web_scale.scalable_dimension
  service_namespace  = aws_appautoscaling_target.app_web_scale.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "app_web_scale_in" {
  count              = length(local.metric_name)
  name               = "${var.environment}_app_web_scale_in_${local.metric_name[count.index]}"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.app_web_scale.resource_id
  scalable_dimension = aws_appautoscaling_target.app_web_scale.scalable_dimension
  service_namespace  = aws_appautoscaling_target.app_web_scale.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}
