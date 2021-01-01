resource "aws_lb" "app_web" {
  name               = "${var.environment}-app-web"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.vpc.security_group_elb.id]
  subnets            = [var.vpc.subnet_public[0].id, var.vpc.subnet_public[2].id]

  access_logs {
    bucket  = "samuraikun-ecs-sample-app-logs"
    prefix  = "elb"
    enabled = true
  }

  tags = {
    "Name"        = "${var.environment}_app_web"
    "Environment" = var.environment
  }
}

resource "aws_lb_listener" "app_web_http" {
  load_balancer_arn = aws_lb.app_web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_web.arn
  }

  # default_action {
  #   type = "redirect"

  #   redirect {
  #     port        = 443
  #     protocol    = "HTTPS"
  #     status_code = "HTTP_301"
  #   }
  # }
}

# resource "aws_lb_listener" "app_web_https" {
#   load_balancer_arn = aws_lb.app_web.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.ecs.web.certificate_arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app_web.arn
#   }
# }

resource "aws_lb_target_group" "app_web" {
  name                 = "${var.environment}-app-web"
  port                 = var.ecs.web.host_port
  protocol             = "HTTP"
  vpc_id               = var.vpc.vpc.id
  deregistration_delay = var.ecs.web.deregistration_delay
  target_type          = "ip"

  health_check {
    interval            = 30
    path                = var.ecs.web.health_check_path
    port                = var.ecs.web.host_port
    protocol            = "HTTP"
    timeout             = 2
    healthy_threshold   = 2
    unhealthy_threshold = 10
    matcher             = 200
  }

  tags = {
    "Name"        = "${var.environment}_app_web"
    "Environment" = var.environment
  }
}
