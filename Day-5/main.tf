# Define the AWS provider configuration.
provider "aws" {
  region = "us-east-1" # Replace with your desired AWS region.
}

# For the VPC 1st we need to define the CIDR block (IP ADDRESS RANGE)
variable "cidr" {
  default = "10.0.0.0/16"
}

# ssh-keygen -t rsa (creates public private key)
resource "aws_key_pair" "example" {
  key_name   = "dev"                              # Replace with your desired key name
  public_key = file("~/.ssh/id_rsa.pub") # Replace with the path to your public key file
}

# Create VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

# Creating the SUBNET, HERE CIDR only for subnet
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}


# Creating IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

# Creating Route TABLE & Attaching IGW 
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associating subnet with route table
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

# Security group and allowing traffic for specific ports
resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
}

# EC2 instance configuration 
resource "aws_instance" "server" {
  ami                    = "ami-0fc5d935ebf8bc3bc"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.example.key_name
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub1.id

# Here we are providing the private key information be'coz public key is updated to the ec2 instance or it is upploaded to the key pair resource of aws 
# But to connect to it we need a private key ( ssh -i private-key ubuntu@<public-ip>)
# Be'coz we are already in the particular resource block you can simply say self.public ip 
# So if you are  outside this resource block to connect to the particular instance public IP or to get the instance public ip you have say
# resource.resource-name.public-ip
  connection {
    type        = "ssh"
    user        = "ubuntu"              # Replace with the appropriate username for your EC2 instance
    private_key = file("~/.ssh/id_rsa") # Replace with the path to your private key
    host        = self.public_ip
  }

  # File provisioner to copy a file from local to the remote EC2 instance
  # This file provisioner is used to copy the file from local to the remote instance
 
  provisioner "file" {
    source      = "app.py"              # Replace with the path to your local file
    destination = "/home/ubuntu/app.py" # Replace with the path on the remote instance
  }


# Using Provisioners we can deploy the application on EC2 instance , To use provisioners we have definitly connect to the instance
# Remote-exec is used to excute all the thehe commands on the remote instance ec2
  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update -y",                  # Update package lists (for ubuntu)
      "sudo apt-get install -y python3-pip", # Example package installation
      "cd /home/ubuntu",
      "sudo pip3 install flask",
      "sudo python3 app.py &",
    ]
  }
}

