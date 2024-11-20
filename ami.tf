data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  name_regex = "^al\\d{4}-ami-\\d{4}.*?-kernel-\\d+\\.\\d+-x86_64$"

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"]
}
