module "ecs_task_execution_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  trusted_role_services = [
    "ecs-tasks.amazonaws.com"
  ]

  create_role = true

  role_name         = "ecsTaskExecutionRole-${var.tags.Name}-${var.tags.Environment}"
  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]

  number_of_custom_role_policy_arns = 1

  tags = var.tags
}

module "ecs_task_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  trusted_role_services = [
    "ecs-tasks.amazonaws.com"
  ]

  create_role = true

  role_name         = "${var.tags.Name}-${var.tags.Environment}"
  role_requires_mfa = false

  custom_role_policy_arns = [
    aws_iam_policy.custom_policy.arn
  ]
  number_of_custom_role_policy_arns = 1

  tags = var.tags
}

resource "aws_iam_policy" "custom_policy" {
  name        = "custom-policy-${var.tags.Name}-${var.tags.Environment}"
  path        = "/"

  policy = data.aws_iam_policy_document.custom_policy.json
}

data "aws_iam_policy_document" "custom_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "s3:ListAllBuckets"
    ]
    resources = ["*"]
  }
}