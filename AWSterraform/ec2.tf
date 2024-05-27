resource "aws_s3_bucket" "mys3" {
  bucket = "testbucket"
}

resource "aws_s3_bucket_public_access_block" "mys3bpa" {
  bucket = aws_s3_bucket.mys3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "mys3acl" {
  bucket = aws_s3_bucket.mys3.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "mys3ver" {
  bucket = aws_s3_bucket.mys3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_instance" "myec2" {
    ami = "ami-005e54dee72cc1d00"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.mysubnet1.id
    vpc_security_group_ids = [ aws_security_group.mysg.id ]
}

resource "aws_lb" "myalb" {
  name = "myalb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.mysg.id]
  subnets = [aws_subnet.mysubnet1.id,aws_subnet.mysubnet2.id]
}
