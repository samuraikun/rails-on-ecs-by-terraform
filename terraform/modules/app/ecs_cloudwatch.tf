resource "aws_cloudwatch_log_group" "ecs_web" {
  name = "${var.environment}-app-web-ecs"
  retention_in_days = var.ecs.web.log_retention_in_days

  tags = {
    Name = "${var.environment}_app_web_ecs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_web_scale_out_cpu" {
  alarm_name          = "${var.environment}_app_web_scale_out_cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.ecs.web.scale_out_by_cpu
  alarm_description   = "This metric monitors ecs cpu utilization for scale out"
  alarm_actions       = [aws_appautoscaling_policy.app_web_scale_out[0].arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.app.name
    ServiceName = aws_ecs_service.app_web.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_web_scale_in_cpu" {
  alarm_name          = "${var.environment}_app_web_scale_in_cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.ecs.web.scale_in_by_cpu
  alarm_description   = "This metric monitors ecs cpu utilization for scale in"
  alarm_actions       = [aws_appautoscaling_policy.app_web_scale_in[0].arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.app.name
    ServiceName = aws_ecs_service.app_web.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_web_scale_out_memory" {
  alarm_name          = "${var.environment}_app_web_scale_out_memory"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.ecs.web.scale_out_by_memory
  alarm_description   = "This metric monitors ecs memory utilization for scale out"
  alarm_actions       = [aws_appautoscaling_policy.app_web_scale_out[1].arn]

  dimensions = {
      ClusterName = aws_ecs_cluster.app.name
      ServiceName = aws_ecs_service.app_web.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_web_scale_in_memory" {
  alarm_name          = "${var.environment}_app_web_scale_in_memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.ecs.web.scale_in_by_memory
  alarm_description   = "This metric monitors ecs memory utilization for scale in"
  alarm_actions       = [aws_appautoscaling_policy.app_web_scale_in[1].arn]

  dimensions = {
      ClusterName = aws_ecs_cluster.app.name
      ServiceName = aws_ecs_service.app_web.name
  }
}
