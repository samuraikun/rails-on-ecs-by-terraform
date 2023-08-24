variable "environment" {}
variable "vpc" {}
variable "database" {}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier              = "${var.environment}-sample-cluster"
  engine                          = "aurora-mysql"
  engine_version                  = "5.7.mysql_aurora.2.09.1"
  availability_zones              = ["ap-northeast-1a", "ap-northeast-1d", "ap-northeast-1c"]
  master_username                 = "root"
  master_password                 = "dummyPassword" // terraform apply後にAWS CLIでパスワード更新
  backup_retention_period         = 1
  preferred_backup_window         = "13:07-13:37"
  preferred_maintenance_window    = "sat:19:00-sat:19:30"
  port                            = 3306
  vpc_security_group_ids          = [var.vpc.security_group_rds.id]
  db_subnet_group_name            = aws_db_subnet_group.sample.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.sample.name
  # snapshot_identifier             = data.aws_db_cluster_snapshot.final_snapshot.id
  enabled_cloudwatch_logs_exports = ["error", "slowquery"]
  storage_encrypted               = true

  lifecycle {
    ignore_changes = [snapshot_identifier]
  }
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  count                   = 2
  identifier              = "${var.environment}-sample-${count.index}"
  cluster_identifier      = aws_rds_cluster.aurora_cluster.id
  instance_class          = var.database.instance_class
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.09.1"
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.sample.name
  db_parameter_group_name = aws_db_parameter_group.sample.name
  promotion_tier          = 1
  copy_tags_to_snapshot   = false
  ca_cert_identifier      = "rds-ca-2019"
  monitoring_interval     = 60
  monitoring_role_arn     = "arn:aws:iam::046977594715:role/rds-monitoring-role"

  tags = {
    Name        = "sample-app-${var.environment}-db-${count.index}"
    Project     = "sample-app"
    Environment = var.environment
  }
}

# data "aws_db_cluster_snapshot" "final_snapshot" {
#   db_cluster_identifier = "collet-staging-cluster"
#   most_recent           = true
# }

resource "aws_db_subnet_group" "sample" {
  name = "sample-app-db"
  subnet_ids = [var.vpc.subnet_public[1].id, var.vpc.subnet_public[4].id]
}

resource "aws_rds_cluster_parameter_group" "sample" {
  name        = "sample-aurora57"
  family      = "aurora5.7"
  description = "Aurora cluster parameter group"

  parameter {
    name  = "log_output"
    value = "FILE"
  }

  parameter {
    name  = "log_queries_not_using_indexes"
    value = 0
  }

  parameter {
    name  = "long_query_time"
    value = 10
  }

  parameter {
    name  = "slow_query_log"
    value = 1
  }
}

resource "aws_db_parameter_group" "sample" {
  name        = "sample-aurora57"
  family      = "aurora5.7"
  description = "Aurora db instance parameter group"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "log_output"
    value = "FILE"
  }

  parameter {
    name  = "log_queries_not_using_indexes"
    value = 0
  }

  parameter {
    name  = "long_query_time"
    value = 10
  }

  parameter {
    name  = "slow_query_log"
    value = 1
  }
}
