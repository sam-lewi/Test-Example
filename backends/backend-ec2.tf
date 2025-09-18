terraform {
  backend "s3" {
    bucket         = "customer-deployment-configs"
    key            = "terraform/ec2/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-ec2"
    encrypt        = true
  }
}