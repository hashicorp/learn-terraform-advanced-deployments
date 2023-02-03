resource "aws_instance" "blue" {
  count = var.enable_blue_env ? var.blue_instance_count : 0

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.private_subnets[count.index % length(module.vpc.private_subnets)]
  vpc_security_group_ids = [module.app_security_group.security_group_id]
  user_data = templatefile("${path.module}/init-script.sh", {
    file_content = "version 1.0 - #${count.index}"
  })

  tags = {
    Name = "blue-${count.index}"
  }
}

resource "aws_lb_target_group" "blue" {
  name     = "blue-tg-${random_pet.app.id}-lb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    port     = 80
    protocol = "HTTP"
    timeout  = 5
    interval = 10
  }
}

resource "aws_lb_target_group_attachment" "blue" {
  count            = length(aws_instance.blue)
  target_group_arn = aws_lb_target_group.blue.arn
  target_id        = aws_instance.blue[count.index].id
  port             = 80
}
