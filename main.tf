
module "vpc" {
  source           = "./modules/vpc"
  virginia_vpc     = var.virginia_vpc
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  route_table_cidr = var.route_table_cidr
  zone             = var.zone
}
