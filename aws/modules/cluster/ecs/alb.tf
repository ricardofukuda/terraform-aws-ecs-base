module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = lower("alb-${module.ecs_cluster.cluster_name}")
  description = "ALB security group"
  vpc_id      = data.aws_vpc.selected.id

  egress_rules = ["all-all"]

  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = var.tags
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = module.ecs_cluster.cluster_name

  load_balancer_type = "application"

  vpc_id             = data.aws_vpc.selected.id
  subnets            = data.aws_subnets.public.ids
  security_groups    = [module.alb_sg.security_group_id]

  target_groups = [
    {
      name      = lower("backend-${var.tags.Environment}")
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type = "instance"
      stickiness = {
        enabled  = true
        type = "lb_cookie"
        cookie_duration = 86400
      }
    },
    {
      name      = lower("backend-ws-${var.tags.Environment}")
      backend_protocol = "HTTP"
      backend_port     = 4000
      target_type = "instance"
      stickiness = {
        enabled  = true
        type = "lb_cookie"
        cookie_duration = 86400
      }
      health_check = {
        enabled =false
      }
    }
  ]

# TODO activate when HTTPS is available
#  https_listeners = [
#    {
#      port               = 443
#      protocol           = "HTTPS"
#      certificate_arn    = data.aws_acm_certificate.cert.arn
#      target_group_index = 0
#    }
#  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Not found!"
        status_code  = "404"
      }
    }

# TODO activate when HTTPS is available
#    {
#      action_type = "redirect"
#      port               = 80
#      protocol           = "HTTP"
#      redirect = {
#        protocol    = "HTTPS"
#        status_code = "HTTP_301"
#      }
#    }
  ]

  http_tcp_listener_rules = [
    {
      http_tcp_listener_index = 0
      priority                = 1

      actions = [{
        type = "forward"
        target_group_index = 0
      }]

      conditions = [{
        host_headers = ["backend.${var.domain}"]
      }]
    },
    {
      http_tcp_listener_index = 0
      priority                = 2

      actions = [{
        type = "forward"
        target_group_index = 1
      }]

      conditions = [{
        host_headers = ["ws.${var.domain}"]
      }]
    },
    {
      http_tcp_listener_index = 0
      priority                = 3

      actions = [{
        type = "redirect"
        status_code = "HTTP_301"
        protocol    = "HTTPS"
        port = 443
        host = "www.${var.domain}"
      }]

      conditions = [{
        host_headers = ["${var.domain}"]
      }]
    }
  ]

  tags = var.tags
}