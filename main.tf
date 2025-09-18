provider "aws" {
  region = var.aws_region
}

resource "random_id" "unique_suffix" {
  byte_length = 4
  count       = local.payload.service_type == "ec2" ? 1 : 0
}

resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
  count     = local.payload.service_type == "ec2" ? 1 : 0
}

resource "aws_key_pair" "ec2_key_pair" {
  count     = local.payload.service_type == "ec2" ? 1 : 0
  key_name   = "client-access-key-${random_id.unique_suffix[0].hex}"
  public_key =  tls_private_key.ec2_key[0].public_key_openssh
  lifecycle {
    ignore_changes = [key_name]
  }
}

output "private_key_pem" {
  value = local.payload.service_type == "ec2" ? tls_private_key.ec2_key[0].private_key_pem : null
  sensitive = true
}

data "aws_s3_object" "payload" {
  bucket = var.s3_payload_bucket
  key    = var.s3_payload_key
}

locals {
  payload = jsondecode(data.aws_s3.object.payload.body)

  instance_keys    = local.payload.service_type == "ec2" ? keys(local.payload.instances) : []
  instance_config  = local.payload.service_type == "ec2" ? local.payload.instances[local.instance_keys[0]] : null
  subnet_id        = local.instance_config != null ? lookup(local.instance_config, "subnet_id", "subnet-DEFAULT") : null

}

module "ec2" {
  source = "./modules/ec2"
  count = local.payload.service_type == "ec2" ? 1 : 0
  instances = local.payload.instances
  key_name = aws_key_pair.ec2_key_pair[0].key_name
  security_group_id =  local.instance_config != null ? local.instance_config.security_groups[0] : null
  subnet_id = local.subnet_id
}

output "ec2_public_ips" {
  value = local.payload.service_type == "ec2" ? module.ec2[0].public_ips : null
}



