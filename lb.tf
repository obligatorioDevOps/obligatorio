resource "aws_lb" "obligatorio" {
  name               = var.project_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.sg_external_alb.security_group_id]
  subnets            = "${module.vpc.public_subnets}"

  enable_deletion_protection = true

 
  tags = {
    Terraform = "true"
    Project = "${var.project_name}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_lb_listener" "obligatorio" {
  load_balancer_arn = aws_lb.obligatorio.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.obligatorio.arn
  }
}

resource "aws_lb_target_group" "obligatorio" {
  name     = "obligatorio-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  
  tags = {
    Terraform = "true"
    Project = "${var.project_name}"
    Environment = "${terraform.workspace}"
  }

}

resource "aws_lb_target_group_attachment" "obligatorio" {
  target_group_arn = aws_lb_target_group.obligatorio.id
  count    = length(data.aws_instances.obligatorio.ids)
  target_id        = data.aws_instances.obligatorio.ids[count.index]
  port             = 80
}

data "aws_instances" "obligatorio" {
  instance_tags = {
    Name = "initial"
  }

  instance_state_names = ["running", "stopped"]
}