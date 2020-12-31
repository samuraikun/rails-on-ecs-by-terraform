resource "aws_iam_role" "ecs_role" {
  name               = "${var.environment}-app-ecs"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com",
          "ecs-tasks.amazonaws.com",
          "application-autoscaling.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
POLICY

  tags = {
    "Name"        = "${var.environment}_app_ecs"
    "Environment" = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ecs_service" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  role       = aws_iam_role.ecs_role.id
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_role.id
}

resource "aws_iam_role_policy_attachment" "ecr_power_user" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.ecs_role.id
}

resource "aws_iam_role_policy" "ecs_secretsmanager" {
  name   = "${var.environment}_ecs_secretsmanager"
  role   = aws_iam_role.ecs_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      "Resource": [
        "arn:aws:ssm:${var.region.name}:${data.aws_caller_identity.self.account_id}:parameter/*",
        "arn:aws:secretsmanager:${var.region.name}:${data.aws_caller_identity.self.account_id}:secret:*",
        "arn:aws:kms:${var.region.name}:${data.aws_caller_identity.self.account_id}:key:*"
      ]
    }
  ]
}
EOF
}
