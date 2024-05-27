resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "mysubnet1" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "mysubnet2" {
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "myig" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myig.id
  }
}

resource "aws_route_table_association" "myrta1" {
  subnet_id = aws_subnet.mysubnet1.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_route_table_association" "myrta2" {
  subnet_id = aws_subnet.mysubnet2.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_security_group" "mysg" {
  name = "sgroup"
  description = "security group creation"
  vpc_id = aws_vpc.myvpc.id
  ingress {
    description = "isg"
    from_port = "80"
    to_port = "80"
    cidr_blocks = "0.0.0.0/0"
    protocol = "tcp"
  }

  egress {
    description = "esg"
    from_port = "80"
    to_port = "80"
    cidr_blocks = "-1"
    protocol = "tcp"
  }
}

resource "aws_lb_target_group" "myalbtg" {
  name = "mytg"
  port = "80"
  protocol = "http"
  vpc_id = aws_vpc.myvpc.id
  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "myalbtga" {
  target_group_arn = aws_lb_target_group.myalbtg.arn
  target_id = aws_instance.myec2.id
  port = "80"
}

resource "aws_lb_listener" "mylbl" {
  load_balancer_arn = aws_lb.myalb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.myalbtg.arn
    type = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}