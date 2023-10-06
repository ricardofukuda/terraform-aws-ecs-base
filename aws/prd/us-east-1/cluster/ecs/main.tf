module "ecs_cluster" {
  source = "../../../../modules/cluster/ecs"

  domain = "fukudatest123.net" # TODO

  tags = var.tags
}