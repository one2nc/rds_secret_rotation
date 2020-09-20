output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

//output "rds_endpoint" {
//  value = module.rds.db_endpoint
//}

//output "secret_arn" {
//  value = module.lambda.secret_arn
//}
