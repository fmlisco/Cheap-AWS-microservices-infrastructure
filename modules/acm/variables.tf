variable "request_certificate" {
  description = "Create ACM SSL certificate"
  type        = bool
  default     = false
}

variable "route53_zone_name" {
  description = "Route53 zone name"
  type        = string
}

variable "tags" {
  description = "A list of tags to apply to all resources"
  type        = map(string)
  default     = {}
}
