data "aws_route53_zone" "this" {
  name         = var.route53_zone_name
  private_zone = false
}

# resource "aws_route53_record" "a_record" {
#     zone_id = data.aws_route53_zone.this.zone_id
#     name    = var.route53_record_name
#     type    = "A"

#     alias {
#         name                   = var.alias_name
#         zone_id                = var.alias_zone_id
#         evaluate_target_health = true
#     }
# }
