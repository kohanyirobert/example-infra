resource "aws_launch_template" "backend" {
  name          = "backend-template"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      aws_security_group.backend.id,
    ]
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ready_tagger_and_ssm_db_password.name
  }

  user_data = base64encode(data.cloudinit_config.backend.rendered)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "${var.project}-backend"
      Project = var.project
    }
  }

  tags = {
    Name    = "${var.project}-backend-template"
    Project = var.project
  }
}

resource "aws_lb_target_group" "backend" {
  name        = "backend-lb-target-group"
  port        = var.backend_target_group_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = var.backend_target_group_health_check_path
    interval            = 5
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Project = var.project
  }
}

resource "aws_autoscaling_group" "backend" {
  name_prefix         = "backend-asg-"
  min_size            = var.backend_min_count
  max_size            = var.backend_max_count
  desired_capacity    = var.backend_desired_count
  vpc_zone_identifier = values(aws_subnet.private)[*].id
  target_group_arns   = [aws_lb_target_group.backend.arn]
  launch_template {
    id      = aws_launch_template.backend.id
    version = aws_launch_template.backend.latest_version
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }
  }

  tag {
    key                 = "Name"
    value               = "backend-asg"
    propagate_at_launch = false
  }

  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = false
  }
}

resource "aws_lb" "backend" {
  name               = "backend-lb"
  internal           = true
  load_balancer_type = "application"
  subnets            = values(aws_subnet.private)[*].id
  security_groups = [
    aws_security_group.backend_lb.id,
  ]

  tags = {
    Project = var.project
  }
}

resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.backend.arn
  port              = var.backend_listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}
