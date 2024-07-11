resource "aws_security_group" "bastion-sg" {
  name        = "bastion-sg"
  description = "Allow SSH inbound traffic"
  vpc_id = "vpc-05a2e61172e49ce58"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private-ec2-sg" {
  name        = "private-ec2-sg"
  description = "Allow Traffic from bastion host and ALB"
  vpc_id = "vpc-05a2e61172e49ce58"

  ingress {
     from_port = 22
     to_port = 22
     protocol = "tcp"
     security_groups = [aws_security_group.bastion-sg.id]
  }
  ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = ["sg-043b64969f27d11d9"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion-host" {
  ami           = "ami-04629cfb3bd2d73f3"
  instance_type = "t2.micro"
  subnet_id = "subnet-0f80d4010443c2586"
  key_name = "new-key"
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  tags = {
    Name = "Bastion Host"
  }
}

resource "aws_instance" "my-server" {
  ami           = "ami-04629cfb3bd2d73f3"
  instance_type = "t2.micro"
  associate_public_ip_address = false
  subnet_id = "subnet-0342ffdc3e6ec296d"
  count = 2
  key_name = "new-key"

  vpc_security_group_ids = [aws_security_group.private-ec2-sg.id]
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
              sudo amazon-linux-extras install epel -y
              sudo yum install ansible -y
              git clone https://github.com/AMH241203/auth-mod-2
              sudo curl -L https://github.com/docker/compose/releases/download/v2.28.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              cd auth-mod-2/
              docker-compose up --build
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
  deletion_protection  = false
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
  port = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-lb-tg.arn
  }
}

resource "aws_alb_target_group_attachment" "targets" {
  for_each = {
    for k, v in aws_instance.my-server:
    k => v
  }
  target_group_arn = aws_lb_target_group.my-lb-tg.arn
  target_id = each.value.id
  
}