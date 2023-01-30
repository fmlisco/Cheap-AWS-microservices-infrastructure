output "vpc_id" {
  value = module.vpc.vpc_id
}
output "vpc_arn" {
  value = module.vpc.vpc_arn
}
output "vpc_public_subnets_ids" {
  value = module.vpc.public_subnets
}
output "vpc_private_subnets_ids" {
  value = module.vpc.private_subnets
}
output "vpc_dbs_subnets_ids" {
  value = module.vpc.intra_subnets
}
# output "vpc_dbs_subnets_ids" {
#   value = aws_subnet.dbs.*.id
# }
