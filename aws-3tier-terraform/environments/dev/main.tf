data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = "${var.project}-${var.environment}"
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "vpc" {
  source = "../../modules/vpc"

  name                     = local.name
  vpc_cidr                 = var.vpc_cidr
  azs                      = local.azs
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  single_nat_gateway       = var.single_nat_gateway
}

module "security_groups" {
  source = "../../modules/security-groups"

  name   = local.name
  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source = "../../modules/alb"

  name               = local.name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_ids = [module.security_groups.alb_sg_id]
}

module "rds" {
  source = "../../modules/rds"

  name                  = local.name
  subnet_ids            = module.vpc.private_db_subnet_ids
  security_group_ids    = [module.security_groups.db_sg_id]
  instance_class        = var.db_instance_class
  db_name               = var.db_name
  username              = var.db_username
  multi_az              = var.db_multi_az
  backup_retention_days = var.db_backup_retention_days
  deletion_protection   = var.db_deletion_protection
  skip_final_snapshot   = var.db_skip_final_snapshot
}

module "iam" {
  source = "../../modules/iam"

  name        = local.name
  secret_arns = [module.rds.secret_arn]
}

module "compute" {
  source = "../../modules/compute"

  name                  = local.name
  environment           = var.environment
  subnet_ids            = module.vpc.private_app_subnet_ids
  security_group_ids    = [module.security_groups.app_sg_id]
  instance_profile_name = module.iam.instance_profile_name
  target_group_arns     = [module.alb.target_group_arn]
  instance_type         = var.instance_type
  min_size              = var.asg_min_size
  max_size              = var.asg_max_size
  desired_capacity      = var.asg_desired_capacity
  db_endpoint           = module.rds.endpoint
}
