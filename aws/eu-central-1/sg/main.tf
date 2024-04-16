terraform {
  backend "s3" {
    bucket         = "aws-terraform-state-backend-reflection"
    key            = "eu-central-1/sg/terraform.tfstate"
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
      "Type"            = "sg"
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
resource "aws_security_group" "sg" {
  name   = "bastion-host-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
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
    Name = "Bastion-host-SG-SSH"
  }
}
