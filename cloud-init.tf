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

data "cloudinit_config" "backend" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "00-install-docker.sh"
    content_type = "text/x-shellscript"
    content      = file("./scripts/install-docker.sh")
  }

  part {
    filename     = "01-deploy-backend.sh"
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/deploy-backend.sh.tftpl", {
      db_private_ip = aws_instance.db.private_ip
    })
  }
}

data "cloudinit_config" "frontend" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "00-install-docker.sh"
    content_type = "text/x-shellscript"
    content      = file("./scripts/install-docker.sh")
  }

  part {
    filename     = "01-deploy-frontend.sh"
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/deploy-frontend.sh.tftpl", {
      backend_lb_dns_name = aws_lb.backend.dns_name
    })
  }
}
