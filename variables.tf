variable "aws_region" {
  description = "AWS region to deploy resources in"
  type = string
  default = "us-east-1"
}

variable "s3_payload_bucket" {
  description = "Name of the S3 bucket containing the payload"
  type = string
}

variable "s3_payload_key" {
  description = "Key of the payload file in the S3 bucket"
  type = string
}

variable "jenkins_url" {
  description = "URL of the Jenkins server"
  type = string
  default = "https://a4a2dbea550e.ngrok-free.app"
}

