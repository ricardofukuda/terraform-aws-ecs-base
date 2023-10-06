module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  create_vpc = true

  name = lower(var.tags.Environment)
  cidr = "10.0.0.0/16"

  azs                  = ["us-east-1c","us-east-1d","us-east-1e","us-east-1f"]
  public_subnets       = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20", "10.0.48.0/20"]
  private_subnets      = ["10.0.96.0/20", "10.0.112.0/20", "10.0.128.0/20", "10.0.144.0/20"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_suffix  = "public"
  private_subnet_suffix = "private"

  enable_flow_log = false

  public_subnet_tags = {
    "Name" = lower("${var.tags.Environment}-public")
  }

  private_subnet_tags = {
    "Name" = lower("${var.tags.Environment}-private")
  }

  private_route_table_tags = {
    "Name" = lower("${var.tags.Environment}-private")
  }

  public_route_table_tags = {
    "Name" = lower("${var.tags.Environment}-public")
  }

  tags = var.tags
}