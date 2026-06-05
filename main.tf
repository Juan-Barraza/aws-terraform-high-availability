
module "vpc" {
  source           = "./modules/vpc"
  virginia_vpc     = var.virginia_vpc
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  route_table_cidr = var.route_table_cidr
  zone             = var.zone
}

module "compute" {
  source                       = "./modules/compute"
  vpc_id                       = module.vpc.vpc_id
  private_subnets_ids          = module.vpc.private_subnet_ids
  public_subnets_ids           = module.vpc.public_subnet_ids
  ingress_port_lis_bkd         = var.ingress_port_lis_bkd
  ingress_port_lis_persistence = var.ingress_port_lis_persistence
  ec2_spects                   = var.ec2_spects
  key_pairs_name               = data.aws_key_pair.key_pair.key_name
  tags                         = var.tags
  target_lb                    = var.target_lb
  ingress_lb                   = var.ingress_lb
  efs_id                       = module.efs.efs_id
}


module "efs" {
  source                        = "./modules/efs"
  vpc_id                        = module.vpc.vpc_id
  tags                          = var.tags
  ingress_efs                   = var.ingress_efs
  private_subnet_ids            = module.vpc.private_subnet_ids
  segurity_group_persistence_id = module.compute.presistence_sg_id
}
