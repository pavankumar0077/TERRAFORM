provider "aws" {
  region = "us-east-1"
}

provider "vault" {
  address = "http://192.168.138.156:8200"
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id = "6745f73a-1307-96b4-43e0-1e44a0f65bfb"
      secret_id = "bc316993-9a34-b607-98c6-cbaa2165eb0d"
    }
  }
}

# TO RETRIVE THE INFORMATION FROM AWS we use data
# TO CREATE RESOURCE WE USE RESOURCE
data "vault_kv_secret_v2" "example" {
  mount = "kv"
  name  = "test-secret"
}


resource "aws_instance" "example" {
  ami = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"

  tags = {
    secret = data.vault_kv_secret_v2.example.data["username"]
  }
}