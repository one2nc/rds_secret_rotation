variable "db_instance" {
  description = "The instance class to use for RDS."
  type        = string
  default     = "db.t2.micro"
}

variable "db_engine" {
  description = "The name of the database engine to be used for RDS."
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "The database engine version."
  type        = string
  default     = "11.6"
}

variable "db_storage_type" {
  description = "Storage Type for RDS."
  type        = string
  default     = "gp2"
}

variable "db_allocated_storage" {
  description = "Storage size in GB."
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Name for the created database."
  type        = string
}

variable "db_backup_window" {
  description = "Preferred backup window."
  type        = string
  default     = "00:00-00:30"
}

variable "db_backup_retention_period" {
  description = "Backup retention period in days."
  type        = string
  default     = "1"
}

variable "private_subnet_id" {
  description = "List of private subnets Ids."
  type        = list(string)
}

variable "enable_skip_final_snapshot" {
  description = "When DB is deleted and If this variable is false, no final snapshot will be made."
  type        = bool
  default     = true
}

variable "enable_public_access" {
  description = "Enable public access for RDS."
  type        = bool
  default     = true
}

variable "enable_multi_az" {
  description = "Create RDS instance in multiple availability zones."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC id in which the RDS instance is to be created."
  type        = string
}

variable "enable_rds_secrets_rotation" {
  description = "Boolean to decide whether to read from AWS Secret Manager or not."
  type        = bool
}

variable "master_username" {
  description = "Database username"
  type        = string
}

variable "master_password" {
  description = "Database password"
  type        = string
}

