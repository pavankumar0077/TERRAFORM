provider "aws" {
  region = "us-east-1" # Set your desired AWS region
}

# Resource creat
resource "aws_instance" "example" {
  ami           = "ami-0fc5d935ebf8bc3bc" # Specify an appropriate AMI ID
  instance_type = "t2.micro"
  subnet_id = "subnet-07320d4a4be94aae4"
  key_name = "dev1"
}