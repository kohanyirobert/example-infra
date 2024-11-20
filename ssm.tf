resource "aws_ssm_parameter" "db_password" {
  name  = "db_password"
  type  = "String"
  value = var.db_password

  tags = {
    Name    = "${var.project}-db_password"
    Project = var.project
  }
}
