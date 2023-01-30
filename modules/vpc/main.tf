module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"

  name            = var.vpc.name
  cidr            = var.vpc.cidr_block
  azs             = var.vpc.azs
  private_subnets = var.vpc.private_subnets
  public_subnets  = var.vpc.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags  = var.vpc.public_subnet_tags
  private_subnet_tags = var.vpc.private_subnet_tags
}