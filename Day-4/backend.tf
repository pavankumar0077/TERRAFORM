terraform {
  backend "s3" {
    bucket = "pavan-s3-check"
    region = "us-east-1"
    key = "pavan/terraform.tfstate"
    dynamodb_table = "terraform_lock"
  }
}