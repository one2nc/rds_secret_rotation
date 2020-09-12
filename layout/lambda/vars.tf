variable "rds_sg" {
  type        = string
  description = "All rotation lambda to communicate to RDS."
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of private subnet ids."
}

variable "rds_name" {
  type        = string
  description = "RDS name"
}

variable "rds_master_username" {
  type        = string
  description = "RDS master username"
}

variable "rds_master_password" {
  type        = string
  description = "RDS master password"
}

variable "rds_host" {
  type        = string
  description = "RDS hostname"
}

variable "rds_cluster_identifier" {
  type        = string
  description = "RDS cluster identifier"
}
