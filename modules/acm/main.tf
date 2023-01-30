data "aws_route53_zone" "this" {
  name         = var.route53_zone_name
  private_zone = false
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "3.3.0"

  domain_name = var.route53_zone_name
  zone_id     = data.aws_route53_zone.this.zone_id

  subject_alternative_names = [
    "*.${var.route53_zone_name}"
  ]

  wait_for_validation = true

  tags = var.tags
}
