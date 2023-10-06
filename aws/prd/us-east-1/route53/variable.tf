variable "tags" {
  default = {
    Service = "Route53"
    Environment = "production"
    Creator     = "Terraform"
  }
}

variable "domain" {
  type = string
  default = "fukudatest123.net" # TODO
}