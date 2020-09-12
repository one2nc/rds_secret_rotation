data "aws_secretsmanager_secret" "by_name" {
  count = var.enable_rds_secrets_rotation ? 1 : 0
  name  = "${var.db_name}-postgres-secret"
}

data "aws_secretsmanager_secret_version" "creds" {
  count     = var.enable_rds_secrets_rotation ? 1 : 0
  secret_id = try(data.aws_secretsmanager_secret.by_name[0].id, "")
}

locals {
  username = try(jsondecode(data.aws_secretsmanager_secret_version.creds[0].secret_string)["username"], var.master_username)
  password = try(jsondecode(data.aws_secretsmanager_secret_version.creds[0].secret_string)["password"], var.master_password)
}

resource "aws_db_instance" "postgres" {
  instance_class          = var.db_instance
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  multi_az                = var.enable_multi_az
  storage_type            = var.db_storage_type
  allocated_storage       = var.db_allocated_storage
  name                    = var.db_name
  username                = local.username
  password                = local.password
  backup_window           = var.db_backup_window
  backup_retention_period = var.db_backup_retention_period
  db_subnet_group_name    = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = var.enable_skip_final_snapshot
  publicly_accessible     = var.enable_public_access
}

resource "aws_db_subnet_group" "db_subnet" {
  subnet_ids = var.private_subnet_id
  name       = "${var.db_name}-subnet-group"
}

resource "aws_security_group" "rotation_lambda_sg" {
  vpc_id = var.vpc_id
  name   = "${var.db_name}-postgres-rotation-lambda-sg"

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_security_group" "rds_sg" {
  vpc_id = var.vpc_id
  name   = "${var.db_name}-postgres-sg"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      aws_security_group.rotation_lambda_sg.id
    ]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}
