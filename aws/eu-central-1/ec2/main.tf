terraform {
  backend "s3" {
    bucket         = "aws-terraform-state-backend-reflection"
    key            = "eu-central-1/ec2/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "aws-terraform-state-locks-reflection"
    encrypt        = true #encryption
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.45.0"
    }
  }
}
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      "TerminationDate" = "Permanent",
      "Environment"     = "Development",
      "Team"            = "DevOps",
      "DeployedBy"      = "Terraform",
      "OwnerEmail"      = "artembrigaz@example.com"
      "Type"            = "Compute Cloud"
    }
  }
}
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "aws-terraform-state-backend-reflection"
    key    = "eu-central-1/vpc/terraform.tfstate"
    region = "eu-central-1"
  }
}
data "terraform_remote_state" "sg" {
  backend = "s3"
  config = {
    bucket = "aws-terraform-state-backend-reflection"
    key    = "eu-central-1/sg/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "ec2_instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "5.6.1"
  name                   = "bastion-host"
  instance_type          = "t2.micro"
  ami                    = "ami-023adaba598e661ac"
  vpc_security_group_ids = [data.terraform_remote_state.sg.outputs.sg_id]
  subnet_id              = data.terraform_remote_state.vpc.outputs.private_subnets[0]
  tags = {
    Name = "Bastion-host"
  }
}
