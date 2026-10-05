terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Find the newest official Ubuntu 22.04 image in this region
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical, the company behind Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Upload your SSH public key so you can log in to the server
resource "aws_key_pair" "me" {
  key_name   = "devops-playground-key"
  public_key = file(pathexpand(var.public_key_path))
}

# Firewall: SSH only from your IP, web (80/443) from anywhere
resource "aws_security_group" "web" {
  name        = "devops-playground-sg"
  description = "SSH from my IP, HTTP and HTTPS from anywhere"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# The server itself. user_data runs once on first boot: install Docker, start the app.
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.me.key_name
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOT
    #!/bin/bash
    set -e
    apt-get update
    apt-get install -y docker.io
    systemctl enable --now docker
    docker run -d --name app --restart unless-stopped -p 80:5000 \
      -e COLOR=teal -e VERSION=aws ${var.app_image}
  EOT

  tags = {
    Name    = "devops-playground"
    Project = "devops-playground"
  }
}
