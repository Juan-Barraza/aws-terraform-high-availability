resource "aws_security_group" "private_instance_bkd_sg" {
  name        = "Sg_001_bkd"
  description = "Allow SHH, ports that you need receive request"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_port_lis_bkd
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.alb_sg.id]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = var.tags.name_sg1
    "env"  = var.tags.env
  }
}

resource "aws_security_group" "private_instance_persistence_sg" {
  name        = "Sg_002_persistence"
  description = " ports that you need receive request"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_port_lis_persistence
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.private_instance_bkd_sg.id]
    }
  }
  egress {
    description     = "NFS to EFS"
    from_port       = var.egress_efs.port_from
    to_port         = var.egress_efs.to_port  
    protocol        = "tcp"
    security_groups = [var.efs_sg_id] 
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = var.tags.name_sg2
    "env"  = var.tags.env
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "Sg_003_lb"
  description = "Allow SHH, ports that you need receive request"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_lb
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = var.tags.name_sg_lb
    "env"  = var.tags.env
  }
}

resource "aws_lb" "alb_instance_bkd" {
  name               = "alb-instance-bkd"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets_ids

  enable_deletion_protection = false # true in production


  tags = {
    "Name"    = var.tags.name_lb
    "env"     = var.tags.env
    ManagedBy = "Terraform"
  }
}

resource "aws_lb_target_group" "bkd_tg" {
  name     = "tg-backend"
  port     = var.target_lb.port
  protocol = var.target_lb.protocol
  vpc_id   = var.vpc_id

  health_check {
    path                = var.target_lb.health_check.path
    protocol            = var.target_lb.health_check.protocol
    matcher             = var.target_lb.health_check.matcher
    interval            = var.target_lb.health_check.interval
    timeout             = var.target_lb.health_check.timeout
    healthy_threshold   = var.target_lb.health_check.healthy_threshold
    unhealthy_threshold = var.target_lb.health_check.unhealthy_threshold
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb_instance_bkd.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    # in this case we need to declarate a certification or not
    type             = var.certificate_arn != null ? "redirect" : "forward"
    target_group_arn = var.certificate_arn != null ? null : aws_lb_target_group.bkd_tg.arn

    dynamic "redirect" {
      for_each = var.certificate_arn != null ? [1] : []
      content {
        port        = "433"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

}


resource "aws_launch_template" "instance_template" {
  name_prefix            = "template_bkd-"
  image_id               = var.ec2_spects.ami
  instance_type          = var.ec2_spects.instance_type_bkd
  vpc_security_group_ids = [aws_security_group.private_instance_bkd_sg.id]
  user_data              = base64encode(file("${path.module}/scripts/setup_docker.sh"))
  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_profile.name
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Name" = var.tags.name_instance_bkd
    "env"  = var.tags.env
  }
}

resource "aws_autoscaling_group" "auto_sg_instance_bkd" {
  name                = "auto_sg_001"
  capacity_rebalance  = true
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1
  force_delete        = true
  health_check_type   = "ELB"
  vpc_zone_identifier = var.private_subnets_ids


  launch_template {
    id      = aws_launch_template.instance_template.id
    version = "$Latest"
  }

}

resource "aws_autoscaling_policy" "cpu_scaling" {
  name                   = "target_tracking_cpu_70"
  autoscaling_group_name = aws_autoscaling_group.auto_sg_instance_bkd.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0 # Is active  when the CPU is over than 70%
  }
}


resource "aws_instance" "aws_instance_persistence" {
  ami                    = var.ec2_spects.ami
  instance_type          = var.ec2_spects.instance_type_persistence
  subnet_id              = var.private_subnets_ids[0]
  key_name               = var.key_pairs_name
  vpc_security_group_ids = [aws_security_group.private_instance_persistence_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  user_data = templatefile("${path.module}/scripts/setup_efs.sh", {
    efs_id = var.efs_id
  })
  tags = {
    "Name" = var.tags.name_instance_p
    "env"  = var.tags.env
  }
}
