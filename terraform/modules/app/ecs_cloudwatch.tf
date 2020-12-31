resource "aws_cloudwatch_log_group" "ecs_web" {
  name = "${var.environment}-app-web-ecs"
  retention_in_days = var.ecs.web.log_retention_in_days

  tags = {
    Name = "${var.environment}_app_web_ecs"
    Environment = var.environment
  }
}
