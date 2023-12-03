provider "aws" {
  region = "us-east-1"
}

# This module can be everywhere like in other github, r any other links
module "ec2_instance" {
  source = "./modules/ec2_instance"
  ami_value = "ami-0fc5d935ebf8bc3bc"
  instance_type_value = "t2.micro"
}