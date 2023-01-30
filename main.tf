# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

################################################################################
# locals
################################################################################
locals {
  name = replace(basename(path.cwd), "_", "-")
  tags = {
    "Name"        = local.name
    "Project"     = var.project
    "Environment" = var.environment
  }
  ingress_cidr_blocks = "0.0.0.0/0"
}


################################################################################
# VPC Module
################################################################################
module "vpc" {
  source = "./modules/vpc"

  vpc = {
    name                 = join("-", ["vpc", "${local.name}"])
    cidr_block           = var.cidr_block
    azs                  = data.aws_availability_zones.available.names
    private_subnets      = var.private_subnets
    public_subnets       = var.public_subnets
    enable_nat_gateway   = true
    single_nat_gateway   = true
    enable_dns_hostnames = true
    enable_vpn_gateway   = false

    public_subnet_tags = {
      "Name" = join("-", ["Public", "${local.name}"])
    }

    private_subnet_tags = {
      "Name" = join("-", ["Application", "${local.name}"])
    }
  }

  tags = local.tags

}

###############################################################################
# ACM Module
###############################################################################
module "acm" {
  source = "./modules/acm"

  route53_zone_name = var.route53_zone_name

  tags = local.tags
}

################################################################################
# ECS Module
################################################################################
module "ecs" {
  source = "./modules/ecs"

  name                = local.name
  vpc_id              = module.vpc.vpc_id
  instance_type       = var.instance_type
  public_subnet_ids   = module.vpc.vpc_public_subnets_ids
  private_subnet_ids  = module.vpc.vpc_private_subnets_ids
  access_log_bucket   = "logs-bucket"
  access_log_prefix   = "ALB"
  health_check_path   = "/health-check/"
  port                = "8080"
  ssl_certificate_arn = module.acm.acm_certificate_arn

  desired_count                  = var.min_size
  min_size                       = var.min_size
  max_size                       = var.max_size
  deployment_min_healthy_percent = "100"
  deployment_max_percent         = "200"
  container_name                 = "haproxy"
  container_port_http            = "80"
  container_port_https           = "443"

  myecrrepo                      = var.myecrrepo

  project             = var.project
  environment         = var.environment
  route53_record_name = var.route53_record_name
  route53_zone_name   = var.route53_zone_name
}
