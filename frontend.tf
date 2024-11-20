resource "aws_launch_template" "frontend" {
  name          = "frontend-template"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      aws_security_group.frontend.id,
    ]
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ready_tagger_only.name
  }

  user_data = base64encode(data.cloudinit_config.frontend.rendered)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "${var.project}-frontend"
      Project = var.project
    }
  }

  tags = {
    Name    = "${var.project}-frontend-template"
    Project = var.project
  }
}

resource "aws_lb_target_group" "frontend" {
  name        = "frontend-lb-target-group"
  port        = var.frontend_target_group_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = var.frontend_target_group_health_check_path
    interval            = 5
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Project = var.project
  }
}

resource "aws_autoscaling_group" "frontend" {
  name_prefix         = "frontend-asg-"
  min_size            = var.frontend_min_count
  max_size            = var.frontend_max_count
  desired_capacity    = var.frontend_desired_count
  vpc_zone_identifier = values(aws_subnet.public)[*].id
  target_group_arns   = [aws_lb_target_group.frontend.arn]
  launch_template {
    id      = aws_launch_template.frontend.id
    version = aws_launch_template.frontend.latest_version
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }
  }

  tag {
    key                 = "Name"
    value               = "frontend-asg"
    propagate_at_launch = false
  }

  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = false
  }
}

resource "aws_lb" "frontend" {
  name               = "frontend-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.frontend_lb.id]
  subnets            = values(aws_subnet.public)[*].id

  tags = {
    Project = var.project
  }
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = var.frontend_listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}
