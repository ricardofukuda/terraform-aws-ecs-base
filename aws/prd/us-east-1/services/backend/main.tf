module "backend" {
  source = "../../../../modules/services/backend"

  subdomain = "backend"
  tags = var.tags
}