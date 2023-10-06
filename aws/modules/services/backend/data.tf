data "aws_ecs_cluster" "ecs_cluster"{
  cluster_name = lower("ecs-${var.tags.Environment}")
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [lower(var.tags.Environment)]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*-private"]
  }
}

data "aws_route53_zone" "zone" {
  name = "fukudatest123.net" # TODO
}

data "aws_lb" "alb" {
  name = data.aws_ecs_cluster.ecs_cluster.cluster_name
}

data "aws_lb_target_group" "tg" {
  name = lower("${var.tags.Name}-${var.tags.Environment}")
}

data "aws_lb_target_group" "tg_ws" {
  name = lower("${var.tags.Name}-ws-${var.tags.Environment}")
}

