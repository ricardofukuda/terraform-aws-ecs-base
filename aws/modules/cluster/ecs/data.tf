data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [lower(var.tags.Environment)]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    Name        = "*-private"
    Environment = lower(var.tags.Environment)
  }
}


data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    Name        = "*-public"
    Environment = lower(var.tags.Environment)
  }
}

data "aws_acm_certificate" "cert"{
  domain      = var.domain
  most_recent = true

  statuses = ["PENDING_VALIDATION", "ISSUED"] # TODO remover o PENDING_ quando o certificado for validado
}