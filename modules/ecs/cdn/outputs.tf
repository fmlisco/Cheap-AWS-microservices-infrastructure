output "cf_dns_name" {
  description = "The domain name corresponding to the distribution"
  value       = module.cdn.cloudfront_distribution_domain_name
}

output "cf_zone_id" {
  description = "The CloudFront Route 53 zone ID"
  value       = module.cdn.cloudfront_distribution_hosted_zone_id
}
