resource "aws_instance" "my-server" {
  ami           = "ami-04629cfb3bd2d73f3"
  instance_type = "t2.micro"
  count = 2
  key_name = "new-key"

  vpc_security_group_ids = ["sg-0ee09a1e4a2ce8f60"]
  tags = {
    Name = "My server ${count.index + 1}"
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install git -y
              sudo yum install docker -y
              sudo systemctl enable docker
              sudo systemctl start docker
              sudo chown ec2-user /var/run/docker.sock
              sudo yum install postgresql16 -y
              EOF
}

resource "aws_db_instance" "mydb" {
  allocated_storage    = 10
  db_name              = "postgres"
  engine               = "postgres"
  engine_version       = "16.3"
  instance_class       = "db.t3.micro"
  username             = "postgres"
  password             = "postgres"
  parameter_group_name = "postgres16"
  skip_final_snapshot  = true
  identifier = "my-database"
  vpc_security_group_ids = ["sg-043274166b565e17a"]
  tags = {
    Name = "My database"
  }
}

resource "aws_lb" "my-lb" {
  name = "my-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = ["sg-043b64969f27d11d9"]
  subnets = ["subnet-0f80d4010443c2586", "subnet-093b699bb3a987e90"]
  enable_deletion_protection = false

  tags = {
    Name = "my-lb"
  }
}

resource "aws_lb_target_group" "my-lb-tg" {
  name = "my-lb-tg"
  target_type = "instance"
  port = 8000
  protocol = "HTTP"
  vpc_id = "vpc-05a2e61172e49ce58"

  health_check {
    path = "/authenticate"
    interval = 30
    healthy_threshold = 5
    unhealthy_threshold = 2
    matcher = "200-399"
    timeout = 5
  }
}

resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.my-lb.arn
  port = 8000
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-lb-tg.arn
  }
}