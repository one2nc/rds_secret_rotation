provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

module "vpc" {
  source               = "./vpc"
  vpc_cidr_block       = var.vpc_cidr_block
  public_subnet_count  = var.public_subnet_count
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_count = var.private_subnet_count
  private_subnet_cidr  = var.private_subnet_cidr
  eip_count            = var.eip_count
}

module "lambda" {
  source                 = "./lambda"
  rds_sg                 = module.rds.rds_rotation_security_group_id
  subnet_ids             = [module.rds.rds_subnet_id]
  rds_master_username    = var.db_rds_username
  rds_master_password    = var.db_rds_password
  rds_host               = module.rds.db_endpoint
  rds_cluster_identifier = "${var.db_rds_dbname}-rds-cluster"
  rds_name               = var.db_rds_dbname
}


module "rds" {
  source                      = "./rds"
  db_name                     = var.db_rds_dbname
  vpc_id                      = module.vpc.vpc_id
  master_username             = var.db_rds_username
  master_password             = var.db_rds_password
  enable_rds_secrets_rotation = var.enable_rds_secret_rotation
  private_subnet_id           = module.vpc.private_subnet_id
}
