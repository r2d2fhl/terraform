
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

# AWS === Configure the AWS Provider
# -------------------------------------------------------------------------------

provider "aws" {
  region  = "eu-central-1"
}

# VPC + Sub === Create a VPC / Subnet
# -------------------------------------------------------------------------------
resource "aws_vpc" "vpc_eldap" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "eldap"
  }
}

resource "aws_subnet" "subnet_eldap" {
  vpc_id = "vpc_eldap"
  cidr_block = "10.0.0.0/24" 
}


# SGR === Create a Security Group
# -------------------------------------------------------------------------------
resource "aws_security_group" "sgr_eldap" {
  name        = "sgr-01-eldap-02032024"
  description = "Allow inbound SSH and HTTP traffic"
  vpc_id      = aws_vpc.vpc_eldap.id
  
  tags = {
    Name = "eldap"
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 === Create a EC2
# -------------------------------------------------------------------------------

resource "aws_instance" "ec2-01-eldap-02032024" {
  ami           = "ami-02fe204d17e0189fb"
  instance_type = "t2.micro"
  subnet_id     = "aws_subnet.subnet_eldap.id"
  # vpc_security_group_ids = [aws_security_group.sgr_eldap.id]

  tags = {
    Name = "eldap"
  }
}

#resource "aws_network_interface_sg_attachment" "sg_attachment" {
#  security_group_id    = aws_security_group.sgr_eldap.id
#  network_interface_id = aws_instance.web.primary_network_interface_id
#}
  


# Resource: aws_ec2_instance_state
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_instance_state
resource "aws_ec2_instance_state" "test" {
  instance_id = aws_instance.ec2-01-eldap-02032024.id
  state       = "stopped"
}





# -------------------------------------------------------------------------------
# Naming Conventions: (all small)
# <resource>-<nm>-<description/info>-<env>-<region>-<ddmmyyyy>
# ec2-01-test-dev-eucentral1-09122023
# vpc-01-eldap-02032024

# Terraform commands:
#   init          Prepare your working directory for other commands
#   validate      Check whether the configuration is valid
#   plan          Show changes required by the current configuration
#   apply         Create or update infrastructure
#   destroy       Destroy previously-created infrastructure
#   
#   terraform -install-autocomplete
# -------------------------------------------------------------------------------

