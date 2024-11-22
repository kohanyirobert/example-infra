data "cloudinit_config" "db" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "00-install-docker.sh"
    content_type = "text/x-shellscript"
    content      = file("./scripts/install-docker.sh")
  }

  part {
    filename     = "01-deploy-postgres.sh"
    content_type = "text/x-shellscript"
    content      = file("./scripts/deploy-postgres.sh")
  }

  part {
    filename     = "02-tag-ready-status.sh"
    content_type = "text/x-shellscript"
    content      = file("./scripts/tag-ready-status.sh")
  }
}

data "cloudinit_config" "api" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "00-install-docker.sh"
    content_type = "text/x-shellscript"
    content      = file("./scripts/install-docker.sh")
  }

  part {
    filename     = "01-deploy-api.sh"
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/deploy-api.sh.tftpl", {
      db_private_ip = aws_instance.db.private_ip
      api_image_tag = var.api_image_tag
    })
  }
}

data "cloudinit_config" "web" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "00-install-docker.sh"
    content_type = "text/x-shellscript"
    content      = file("./scripts/install-docker.sh")
  }

  part {
    filename     = "01-deploy-web.sh"
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/deploy-web.sh.tftpl", {
      api_lb_dns_name = aws_lb.api.dns_name
      web_image_tag   = var.web_image_tag
    })
  }
}
