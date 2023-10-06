variable "tags" {
  default = {
    Name = "backend"
    Service = "ECS"
    Environment = "production"
    Creator     = "Terraform"
  }
}
