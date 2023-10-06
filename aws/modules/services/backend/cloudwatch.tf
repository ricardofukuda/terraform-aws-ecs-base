resource "aws_cloudwatch_log_group" "group" {
  name              = lower("${var.tags.Name}-${var.tags.Environment}")
  retention_in_days = 30

  tags = var.tags
}

resource "aws_cloudwatch_log_stream" "stream" {
  name           = lower("${var.tags.Name}")
  log_group_name = aws_cloudwatch_log_group.group.name
}