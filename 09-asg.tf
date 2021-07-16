resource "aws_autoscaling_group" "asg" {
  name                = "asg"
  max_size            = 9
  min_size            = 3
  desired_capacity    = 4
  vpc_zone_identifier = "${aws_subnet.pub-subnets[*].id}"
  health_check_type   = "EC2"

  launch_template {
    id      = "${aws_launch_template.template.id}"
    version = "${aws_launch_template.template.latest_version}"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 75
    }
  }

}

resource "aws_autoscaling_attachment" "asg-attach" {
  autoscaling_group_name  = "${aws_autoscaling_group.asg.id}"
  alb_target_group_arn    = "${aws_lb_target_group.tg-group.id}"
}

resource "aws_autoscaling_policy" "asg-policy" {
  name                    = "policy-asg"
  autoscaling_group_name  = "${aws_autoscaling_group.asg.id}"
  policy_type             = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
  }
}