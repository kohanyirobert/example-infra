resource "aws_instance" "db" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.private["primary"].id
  iam_instance_profile        = aws_iam_instance_profile.ready_tagger_and_ssm_db_password.name

  vpc_security_group_ids = [
    aws_security_group.db.id,
  ]

  user_data                   = data.cloudinit_config.db.rendered
  user_data_replace_on_change = true

  tags = {
    Name    = "${var.project}-db"
    Project = var.project
  }

  depends_on = [aws_ssm_parameter.db_password]
}

resource "terraform_data" "wait_for_db" {
  provisioner "local-exec" {
    interpreter = [var.local_bash_executable_path, "-c"]
    command = templatefile("scripts/wait-for-ready-status-tag.sh.tftpl", {
      instance_id = aws_instance.db.id
    })
  }
}
