provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

resource "aws_vpc" "terraform" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "terraform-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.terraform.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}
resource "aws_subnet" "publicb" {
  vpc_id                  = aws_vpc.terraform.id
  cidr_block              = var.public_subnet_cidr_block_b
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.terraform.id
  cidr_block              = var.private_subnet_cidr_block
  availability_zone       = "${var.region}b"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "terranet" {
  vpc_id = aws_vpc.terraform.id

  tags = {
    Name = "terranet-igw"
  }
}

resource "aws_security_group" "terrasg" {
  name        = "terrasg-sg"
  description = "Example security group"
  vpc_id      = aws_vpc.terraform.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_launch_configuration" "terraec2" {
  name = "terraec2_config"
  
  image_id        = var.ami
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.terrasg.id] # Change to your security group ID
  
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install nginx1.12 -y
              sudo service nginx start
              sudo chkconfig nginx on
              EOF
}

resource "aws_autoscaling_group" "terraau" {
  desired_capacity     = var.desired_capacity
  min_size             = var.min_size
  max_size             = var.max_size
  launch_configuration = aws_launch_configuration.terraec2.id #configured to ec2 instance
  vpc_zone_identifier =  [aws_subnet.private.id]
  health_check_type          = "EC2"
  health_check_grace_period  = 300
  force_delete               = true

  tag {
    key                 = "Name"
    value               = "nginex-instance"
    propagate_at_launch = true
  }
}
resource "aws_lb" "terralb" {
  name               = "terralb-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.terrasg.id]
  subnets            = [aws_subnet.public.id, aws_subnet.publicb.id]
  
  enable_deletion_protection = false
}

resource "aws_lb_listener" "terralbls" {
  load_balancer_arn = aws_lb.terralb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "OK"
    }
  }
}

resource "aws_lb_target_group" "terratarget" {
  name     = "terralb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.terraform.id
}

resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.terraau.name
  lb_target_group_arn       = aws_lb_target_group.terratarget.arn
}

output "load_balancer_dns"{
  value = aws_lb.terralb.dns_name
}
