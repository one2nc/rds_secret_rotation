variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "public_subnet_count" {
  type = number
}

variable "private_subnet_count" {
  type = number
}

variable "public_subnet_cidr" {
  type = list(string)
}

variable "private_subnet_cidr" {
  type = list(string)
}

variable "eip_count" {
  type = number
}

variable "db_rds_dbname" {
  type = string
}

variable "db_rds_username" {
  type = string
}

variable "db_rds_password" {
  type = string
}

variable "enable_rds_secret_rotation" {
  type = bool
}
