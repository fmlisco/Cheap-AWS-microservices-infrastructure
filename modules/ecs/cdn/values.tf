variable "price_class" {
  description = "The price class for distribution (PriceClass_All, PriceClass_200, PriceClass_100)"
  type        = string
  default     = "PriceClass_100"
}

variable "origin_domain_name" {
  description = "Origin domain name - in this case LB domain name"
  type        = string
}

variable "aliases" {
  description = "Extra CNAMEs (alternate domain names), for this distribution"
  type        = list(string)
}

variable "certificate_arn" {
  description = "The ACM certificate ARN for this distribution"
  type        = string
  default     = null
}

variable "tags" {
  description = "A list of tags to apply to all resources"
  type        = map(string)
  default     = {}
}