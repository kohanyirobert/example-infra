resource "aws_launch_template" "web" {
  name          = "web-template"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      aws_security_group.web.id,
    ]
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ready_tagger_only.name
  }

  user_data = base64encode(data.cloudinit_config.web.rendered)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "${var.project}-web"
      Project = var.project
    }
  }

  tags = {
    Name    = "${var.project}-web-template"
    Project = var.project
  }
}

resource "aws_lb_target_group" "web" {
  name        = "web-lb-target-group"
  port        = var.web_target_group_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = var.web_target_group_health_check_path
    interval            = 5
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Project = var.project
  }
}

resource "aws_autoscaling_group" "web" {
  name_prefix         = "web-asg-"
  min_size            = var.web_min_count
  max_size            = var.web_max_count
  desired_capacity    = var.web_desired_count
  vpc_zone_identifier = values(aws_subnet.public)[*].id
  target_group_arns   = [aws_lb_target_group.web.arn]
  launch_template {
    id      = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }
  }

  tag {
    key                 = "Name"
    value               = "web-asg"
    propagate_at_launch = false
  }

  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = false
  }
}

resource "aws_lb" "web" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_lb.id]
  subnets            = values(aws_subnet.public)[*].id

  tags = {
    Project = var.project
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = var.web_listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
