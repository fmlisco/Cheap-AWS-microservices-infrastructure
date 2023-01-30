################################################################################
# Generic variables
################################################################################
variable "environment" {}
variable "instance_type" {}
variable "myecrrepo" {}
variable "project" {}
variable "tags" {
  type = object({
    Name = string
  })

  default = {
    Name = "SimpleECSCluster"
  }
}
################################################################################
# VPC Module
################################################################################
variable "cidr_block" {}
variable "private_subnets" {}
variable "public_subnets" {}
variable "dbs_subnets" {}
################################################################################
# DNS Module
################################################################################
variable "route53_zone_name" {
  description = "Route53 zone name"
  type        = string
}
variable "route53_record_name" {
  description = "Name of Route53 record "
  type        = string
}
################################################################################
# ECS Module
################################################################################
variable "min_size" {}
variable "max_size" {}