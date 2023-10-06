module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.2.2"

  cluster_name = lower("ecs-${var.tags.Environment}")

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  autoscaling_capacity_providers = {
    EC2_OD_SMALL = {
      auto_scaling_group_arn         = module.autoscaling["EC2_OD_SMALL"].autoscaling_group_arn
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 5
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 100
      }

      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  default_capacity_provider_use_fargate = false
  cloudwatch_log_group_retention_in_days = 30

  tags = var.tags
}