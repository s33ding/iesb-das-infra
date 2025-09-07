module "vpc" {
  source = "./modules/vpc"

  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
  az_count     = var.availability_zones_count
}

module "eks" {
  source = "./modules/eks"

  project_name        = var.project_name
  subnet_ids          = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  private_subnet_ids  = module.vpc.private_subnet_ids
  node_desired_size   = var.node_desired_size
  node_max_size       = var.node_max_size
  node_min_size       = var.node_min_size
  node_instance_types = var.node_instance_types
  allowed_cidr_blocks = var.allowed_cidr_blocks
  eks_admin_users     = var.eks_admin_users
}
