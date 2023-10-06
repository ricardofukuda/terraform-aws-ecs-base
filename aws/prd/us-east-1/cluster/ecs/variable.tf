variable "tags" {
  default = {
    Service = "ECS"
    Environment = "production"
    Creator     = "Terraform"
  }
}
