resource "aws_s3_bucket" "mys3" {
  bucket = "testbucket"
  tags = {
    name = "myfirstbucket"
  }
}



