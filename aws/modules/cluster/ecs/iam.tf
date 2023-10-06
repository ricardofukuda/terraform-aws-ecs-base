module "ecsTaskExecutionRole" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  trusted_role_services = [
    "ecs-tasks.amazonaws.com"
  ]

  create_role = true

  role_name         = "ecsTaskExecutionRole-${lower(var.tags.Environment)}"
  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]

  number_of_custom_role_policy_arns = 1

  tags = var.tags
}