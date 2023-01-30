# output "fqdns" {
#   description = "The FQDNs of the Route53 resource"
#   value       = element(concat(aws_route53_record.a_record.*.fqdn, [""]), 0)
# }