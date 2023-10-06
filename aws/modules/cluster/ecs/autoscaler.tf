module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.5"

  for_each = {
    EC2_OD_SMALL = {
      instance_type              = "t3a.small"
      user_data                  = <<-EOT
        #!/bin/bash
        cat <<'EOF' >> /etc/ecs/ecs.config
        ECS_CLUSTER=${module.ecs_cluster.cluster_name}
        ECS_LOGLEVEL=debug
        ECS_CONTAINER_INSTANCE_TAGS=${jsonencode(var.tags)}
        ECS_ENABLE_TASK_IAM_ROLE=true
        EOF
      EOT
    }
  }

  name = "${module.ecs_cluster.cluster_name}-${each.key}"

  image_id      = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type = each.value.instance_type

  security_groups                 = [module.autoscaling_sg.security_group_id]
  user_data                       = base64encode(each.value.user_data)
  ignore_desired_capacity_changes = true

  create_iam_instance_profile = true
  iam_role_name               = module.ecs_cluster.cluster_name
  iam_role_description        = "ECS role for ${module.ecs_cluster.cluster_name}"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  vpc_zone_identifier = data.aws_subnets.private.ids
  health_check_type   = "EC2"
  min_size            = 0
  max_size            = 5
  desired_capacity    = 0

  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  credit_specification = {
    cpu_credits = "standard"
  }

  protect_from_scale_in = true

  use_mixed_instances_policy = false
  mixed_instances_policy     = {}

  tags = var.tags
}

module "autoscaling_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = module.ecs_cluster.cluster_name
  description = "ECS EC2 Instance security group"
  vpc_id      = data.aws_vpc.selected.id

  egress_rules = ["all-all"]

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  tags = var.tags
}