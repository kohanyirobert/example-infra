resource "aws_launch_template" "api" {
  name          = "api-template"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      aws_security_group.api.id,
    ]
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ready_tagger_and_ssm_db_password.name
  }

  user_data = base64encode(data.cloudinit_config.api.rendered)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "${var.project}-api"
      Project = var.project
    }
  }

  tags = {
    Name    = "${var.project}-api-template"
    Project = var.project
  }
}

resource "aws_lb_target_group" "api" {
  name        = "api-lb-target-group"
  port        = var.api_target_group_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = var.api_target_group_health_check_path
    interval            = 5
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Project = var.project
  }
}

resource "aws_autoscaling_group" "api" {
  name_prefix         = "api-asg-"
  min_size            = var.api_min_count
  max_size            = var.api_max_count
  desired_capacity    = var.api_desired_count
  vpc_zone_identifier = values(aws_subnet.private)[*].id
  target_group_arns   = [aws_lb_target_group.api.arn]
  launch_template {
    id      = aws_launch_template.api.id
    version = aws_launch_template.api.latest_version
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }
  }

  tag {
    key                 = "Name"
    value               = "api-asg"
    propagate_at_launch = false
  }

  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = false
  }
}

resource "aws_lb" "api" {
  name               = "api-lb"
  internal           = true
  load_balancer_type = "application"
  subnets            = values(aws_subnet.private)[*].id
  security_groups = [
    aws_security_group.api_lb.id,
  ]

  tags = {
    Project = var.project
  }
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.api.arn
  port              = var.api_listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}
