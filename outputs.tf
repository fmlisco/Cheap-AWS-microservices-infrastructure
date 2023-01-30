################################################################################
# VPC Module
################################################################################
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "vpc_arn" {
  value = module.vpc.vpc_arn
}
output "vpc_public_subnets_ids" {
  value = module.vpc.vpc_public_subnets_ids
}
output "vpc_private_subnets_ids" {
  value = module.vpc.vpc_private_subnets_ids
}
output "vpc_dbs_subnets_ids" {
  value = module.vpc.vpc_dbs_subnets_ids
}

output "acm_certificate_arn" {
  description = "The ARN of the certificate"
  value       = module.acm.acm_certificate_arn
}

