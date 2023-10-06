resource "aws_ecs_task_definition" "task_definition" {
  family = lower("${var.tags.Name}-${var.tags.Environment}")

  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"

  cpu       = 256
  memory    = 512

  task_role_arn = module.ecs_task_role.iam_role_arn
  execution_role_arn = module.ecs_task_execution_role.iam_role_arn

  container_definitions = jsonencode([
    {
      name      = "main"
      image     = "httpd:2.4"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort = 0
          protocol = "http"
        },
        {
          containerPort = 4000
          hostPort = 0
          protocol = "http"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.group.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = lower("${var.tags.Name}")
        }
      }
    }
  ])

  tags = var.tags
}

resource "aws_ecs_service" "ecs_service" {
  name            = lower("${var.tags.Name}")
  cluster         = data.aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  
  desired_count   = 2

  capacity_provider_strategy {
    capacity_provider = "EC2_OD_SMALL"
    weight = 100
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "host"
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.tg.arn
    container_name   = "main"
    container_port   = 80
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.tg_ws.arn
    container_name   = "main"
    container_port   = 4000
  }
}
