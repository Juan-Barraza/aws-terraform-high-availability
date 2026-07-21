
module "vpc" {
  source           = "./modules/vpc"
  virginia_vpc     = var.virginia_vpc
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  route_table_cidr = var.route_table_cidr
  zone             = var.zone
}

module "efs" {
  source             = "./modules/efs"
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = module.vpc.vpc_cidr
  tags               = var.tags
  ingress_efs        = var.ingress_efs
  private_subnet_ids = module.vpc.private_subnet_ids
}
module "compute" {
  source                       = "./modules/compute"
  vpc_id                       = module.vpc.vpc_id
  private_subnets_ids          = module.vpc.private_subnet_ids
  public_subnets_ids           = module.vpc.public_subnet_ids
  ingress_port_lis_bkd         = var.ingress_port_lis_bkd
  ingress_port_lis_persistence = var.ingress_port_lis_persistence
  ec2_spects                   = var.ec2_spects
  tags                         = var.tags
  target_lb                    = var.target_lb
  ingress_lb                   = var.ingress_lb
  efs_id                       = module.efs.efs_id
  efs_sg_id                    = module.efs.efs_sg_id
  egress_efs                   = var.ingress_efs
  depends_on                   = [module.vpc, module.efs]
}

module "ses" {
  source                = "./modules/ses"
  notification_email    = var.notification_email
  enable_ses_monitoring = var.enable_ses_monitoring
  use_domain_identity   = var.use_domain_identity
  ses_domain            = var.ses_domain
}
