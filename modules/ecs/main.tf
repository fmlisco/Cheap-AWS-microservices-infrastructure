data "template_file" "container_definition" {
  template = "${file("${path.module}/container-definition.tpl")}"

  vars = {
    myecrrepo   = var.myecrrepo
    environment = var.environment
  }
}

locals {
  user_data = <<-EOT
        #!/bin/bash
        cat <<'EOF' >> /etc/ecs/ecs.config
        ECS_CLUSTER=${var.name}
        ECS_LOGLEVEL=debug
        EOF
    EOT

  cdn_dns_prefix = "cdn-"
  fqdn_cdn_alias = "${local.cdn_dns_prefix}${var.route53_record_name}.${var.route53_zone_name}"

  tags = {
    Name       = var.name
    Example    = var.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-ecs"
  }
}

################################################################################
# ECS Module
################################################################################

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "ecs-${var.name}"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.this.name
      }
    }
  }

  default_capacity_provider_use_fargate = false

  # Capacity provider - Fargate
  fargate_capacity_providers = {
    FARGATE      = {}
    FARGATE_SPOT = {}
  }

  # Capacity provider - autoscaling groups
  autoscaling_capacity_providers = {
    one = {
      auto_scaling_group_arn         = module.autoscaling["one"].autoscaling_group_arn
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 5
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 60
      }

      default_capacity_provider_strategy = {
        weight = 100
        base   = 100
      }
    }
  }

  tags = local.tags
}

################################################################################
# ECS resources
################################################################################
resource "aws_ecs_task_definition" "this" {
  lifecycle {
    create_before_destroy = true
  }

  family                = var.project
  container_definitions = data.template_file.container_definition.rendered
  network_mode          = "awsvpc"
}

resource "aws_ecs_service" "main" {
  name            = "ecs-${var.environment}-${var.name}"
  cluster         = module.ecs.cluster_id
  task_definition = "${aws_ecs_task_definition.this.family}:${max(aws_ecs_task_definition.this.revision, aws_ecs_task_definition.this.revision)}"

  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.deployment_min_healthy_percent
  deployment_maximum_percent         = var.deployment_max_percent

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.main.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.id
    container_name   = var.container_name
    container_port   = var.container_port_http
  }
}

###############################################################################
# Security group resources
###############################################################################
resource "aws_security_group" "main" {
  vpc_id = var.vpc_id

  tags = {
    Name        = "sg-${var.name}-LoadBalancer"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "lb_http_ingress" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "lb_https_ingress" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.main.id
}

################################################################################
# ALB resources
################################################################################
resource "aws_alb" "main" {
  security_groups = [aws_security_group.main.id]
  subnets         = var.public_subnet_ids
  name            = "alb-${var.environment}-${var.name}"

  access_logs {
    bucket = var.access_log_bucket
    prefix = var.access_log_prefix
  }

  tags = {
    Name        = "alb${var.environment}${var.name}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_target_group" "main" {
  name = "tg-${var.environment}-${var.name}"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }

  port        = var.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  tags = {
    Name        = "tg-${var.environment}-${var.name}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}
resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.main.id
  port              = var.container_port_https
  protocol          = "HTTPS"

  certificate_arn = var.ssl_certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.main.id
  port              = var.container_port_http
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}

################################################################################
# Cloudfront resources
################################################################################
module "cdn" {
  source = "./cdn"

  aliases            = [local.fqdn_cdn_alias]
  origin_domain_name = aws_alb.main.dns_name
  certificate_arn    = var.ssl_certificate_arn
}

################################################################################
# Application AutoScaling resources
################################################################################

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html#ecs-optimized-ami-linux
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.5"

  for_each = {
    one = {
      instance_type = var.instance_type
    }
  }

  name = "${var.name}-${each.key}"

  image_id      = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type = each.value.instance_type

  security_groups                 = [module.autoscaling_sg.security_group_id]
  user_data                       = base64encode(local.user_data)
  ignore_desired_capacity_changes = true

  create_iam_instance_profile = true
  iam_role_name               = var.name
  iam_role_description        = "ECS role for ${var.name}"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  vpc_zone_identifier = var.private_subnet_ids
  health_check_type   = "EC2"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.min_size

  # https://github.com/hashicorp/terraform-provider-aws/issues/12582
  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  # Required for  managed_termination_protection = "ENABLED"
  protect_from_scale_in = true

  tags = local.tags
}

module "autoscaling_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = var.name
  description = "Autoscaling group security group"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp"]

  egress_rules = ["all-all"]

  tags = local.tags
}

################################################################################
# Cloudwatch resources
################################################################################
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${var.name}"
  retention_in_days = 7

  tags = local.tags
}
###############################################################################
# Route53 Module
###############################################################################
# module "route53" {
#     source = "./dns"

#     route53_zone_name   = var.route53_zone_name
#     route53_record_name = "${local.cdn_dns_prefix}${var.route53_record_name}"
# #   alias_name          = module.ecs[0].cf_dns_name
# #   alias_zone_id       = module.ecs[0].cf_zone_id
# }