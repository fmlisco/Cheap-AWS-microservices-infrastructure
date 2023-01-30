module "cdn" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "2.9.2"

  aliases     = var.aliases
  price_class = var.price_class

  origin = {
    alb = {
      domain_name = var.origin_domain_name
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "alb"
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
    cookies         = true
    min_ttl         = 0
    default_ttl     = 3600
    max_ttl         = 86400
  }

  viewer_certificate = {
    acm_certificate_arn = var.certificate_arn
    ssl_support_method  = "sni-only"
  }

  tags = var.tags
}