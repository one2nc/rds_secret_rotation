data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "secrets_manager_rds_rotation_single_user_role_policy" {
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DetachNetworkInterface",
    ]
    resources = ["*", ]
  }
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:*",
    ]
  }
  statement {
    actions   = ["secretsmanager:GetRandomPassword"]
    resources = ["*", ]
  }
}

resource "aws_iam_policy" "secrets_manager_rds_rotation_single_user_role_policy" {
  name   = "${var.rds_name}-sm-rds-rotation-single-user-role-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.secrets_manager_rds_rotation_single_user_role_policy.json
}

resource "aws_lambda_permission" "allow_secret_manager_call_lambda" {
  function_name = aws_lambda_function.rotate_code_postgres.function_name
  statement_id  = "AllowExecutionSecretManager"
  action        = "lambda:InvokeFunction"
  principal     = "secretsmanager.amazonaws.com"
}

resource "aws_iam_policy_attachment" "secrets_manager_rds_rotation_single_user_role_policy" {
  name       = "${var.rds_name}-sm-rds-rotation-single-user-role-policy"
  roles      = ["${aws_iam_role.lambda_rotation.name}"]
  policy_arn = aws_iam_policy.secrets_manager_rds_rotation_single_user_role_policy.arn
}

resource "aws_iam_role" "lambda_rotation" {
  name               = "${var.rds_name}-lambda-rotation"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "${var.rds_name}-lambda-logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_rotation.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_lambda_function" "rotate_code_postgres" {
  filename         = "${path.module}/rotate.zip"
  function_name    = "${var.rds_name}-rds-rotation-lambda"
  role             = aws_iam_role.lambda_rotation.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/rotate.zip")
  runtime          = "python3.7"
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.rds_sg]
  }
  timeout     = 30
  description = "Conducts an AWS SecretsManager secret rotation for RDS using single user rotation scheme"
  environment {
    variables = {
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${data.aws_region.current.name}.amazonaws.com"
    }
  }
}

resource "aws_secretsmanager_secret" "secret" {
  description         = "RDS Credentials of ${var.rds_name} service"
  name                = "postgres/${var.rds_name}"
  rotation_lambda_arn = aws_lambda_function.rotate_code_postgres.arn
  rotation_rules {
    automatically_after_days = "30"
  }
}

resource "aws_secretsmanager_secret_version" "secret" {
  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = <<EOF
{
  "username": "${var.rds_master_username}",
  "password": "${var.rds_master_password}",
  "engine": "postgres",
  "host": "${var.rds_host}",
  "port": 5432,
  "dbClusterIdentifier": "${var.rds_cluster_identifier}",
  "db" : "${var.rds_name}"
}
EOF
}
