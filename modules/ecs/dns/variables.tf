variable "alias_name" {
  description = "DNS domain name of alias AWS resource"
  type        = string
}
variable "alias_zone_id" {
  description = "DNS zone id of alias AWS resource"
  type        = string
}
variable "route53_zone_name" {
  description = "Route53 zone name"
  type        = string
}

variable "route53_record_name" {
  description = "Name of Route53 record"
  type        = string
}

